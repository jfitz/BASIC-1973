# the interpreter
class Interpreter
  attr_reader :current_line_index
  attr_accessor :next_line_index
  attr_reader :console_io
  attr_reader :trace_out
  attr_reader :if_false_next_line
  attr_reader :fornext_one_beyond
  attr_reader :start_time

  def initialize(console_io, int_floor, ignore_rnd_arg, randomize,
                 respect_randomize, if_false_next_line, fornext_one_beyond,
                 lock_fornext, require_initialized)
    @running = false
    @randomizer = Random.new(1)
    @randomizer = Random.new if randomize && respect_randomize
    @respect_randomize = respect_randomize
    @int_floor = int_floor
    @ignore_rnd_arg = ignore_rnd_arg
    @console_io = console_io
    @data_store = DataStore.new
    @file_handlers = {}
    @return_stack = []
    @fornexts = {}
    @dimensions = {}
    @user_functions = {}
    @user_var_names = {}
    @user_var_values = []
    @program_lines = {}
    @variables = {}
    @get_value_seen = []
    @if_false_next_line = if_false_next_line
    @fornext_one_beyond = fornext_one_beyond
    @lock_fornext = lock_fornext
    @locked_variables = []
    @require_initialized = require_initialized
    @start_time = nil
    @null_out = NullOut.new
    @tokenbuilders = make_debug_tokenbuilders
    @breakpoints = {}
  end

  private

  def make_debug_tokenbuilders
    tokenbuilders = []

    keywords = %w(GO STOP STEP BREAK LIST PRETTY DELETE PROFILE DIM GOTO LET PRINT)
    tokenbuilders << ListTokenBuilder.new(keywords, KeywordToken)

    un_ops = UnaryOperator.operators(false)
    bi_ops = BinaryOperator.operators(false)
    operators = (un_ops + bi_ops).uniq
    tokenbuilders << ListTokenBuilder.new(operators, OperatorToken)

    tokenbuilders << BreakTokenBuilder.new

    tokenbuilders << ListTokenBuilder.new(['(', '['], GroupStartToken)
    tokenbuilders << ListTokenBuilder.new([')', ']'], GroupEndToken)
    tokenbuilders << ListTokenBuilder.new([',', ';'], ParamSeparatorToken)

    tokenbuilders <<
      ListTokenBuilder.new(FunctionFactory.function_names, FunctionToken)

    function_names = ('FNA'..'FNZ').to_a
    tokenbuilders << ListTokenBuilder.new(function_names, UserFunctionToken)

    tokenbuilders << TextTokenBuilder.new
    tokenbuilders << NumberTokenBuilder.new(false)
    tokenbuilders << IntegerTokenBuilder.new
    tokenbuilders << VariableTokenBuilder.new
    tokenbuilders << ListTokenBuilder.new(%w(TRUE FALSE), BooleanConstantToken)

    tokenbuilders << WhitespaceTokenBuilder.new
  end

  def verify_next_line_index
    raise BASICRuntimeError, 'Program terminated without END' if
      @next_line_index.nil?
    line_numbers = @program_lines.keys
    unless line_numbers.include?(@next_line_index.number)
      raise(BASICRuntimeError, "Line number #{@next_line_index.number} not found")
    end
  end

  public

  def run(program, trace_flag, show_timing, show_profile)
    if program.empty?
      @console_io.print_line('No program loaded')
      return
    end

    @program = program
    @program_lines = program.lines
    @trace_flag = trace_flag
    @step_mode = false

    # reset profile metrics
    @program_lines.keys.sort.each do |line_number|
      line = @program_lines[line_number]
      statements = line.statements
      statements.each do |statement|
        statement.profile_count = 0
        statement.profile_time = 0
      end
    end

    @start_time = Time.now
    timing = Benchmark.measure { run_and_time }
    print_timing(timing) if show_timing
    if show_profile
      line_list_spec = program.line_list_spec('')
      @program.profile(line_list_spec)
    end
  end

  def run_and_time
    # run the program
    @variables = {}
    @trace_out = @trace_flag ? @console_io : @null_out
    @running = true
    run_phase_1
    run_phase_2 if @running
  end

  def print_timing(timing)
    user_time = timing.utime + timing.cutime
    sys_time = timing.stime + timing.cstime
    @console_io.newline
    @console_io.print_line('CPU time:')
    @console_io.print_line(" user: #{user_time.round(2)}")
    @console_io.print_line(" system: #{sys_time.round(2)}")
    @console_io.newline
  end

  def run_phase_1
    # phase 1: do all initialization (store values in DATA lines)
    line_number = @program_lines.min[0]
    @current_line_index = LineNumberIndex.new(line_number, 0, 0)
    preexecute_loop
  end

  def run_phase_2
    # phase 2: run each command
    # start with the first line number
    line_number = @program_lines.min[0]
    @current_line_index = LineNumberIndex.new(line_number, 0, 0)
    begin
      program_loop while @running
    rescue Interrupt
      stop_running
    end
    @file_handlers.each { |_, fh| fh.close }
  end

  def print_trace_info(statement)
    @trace_out.newline_when_needed
    @trace_out.print_out @current_line_index.to_s + ':' + statement.pretty
    @trace_out.newline
  end

  def print_errors(line_number, statement)
    @console_io.print_line("Errors in line #{line_number}:")
    statement.errors.each { |error| puts error }
  end

  def preexecute_a_statement
    line_number = @current_line_index.number
    line = @program_lines[line_number]
    statements = line.statements
    statement_index = @current_line_index.statement
    statement = statements[statement_index]

    if statement.errors.empty?
      statement.pre_execute(self)
    else
      stop_running
      print_errors(line_number, statement)
    end
  end

  def preexecute_loop
    while !@current_line_index.nil? && @running
      preexecute_a_statement
      @current_line_index = @program.find_next_line_index(@current_line_index)
    end
  rescue BASICRuntimeError => e
    line_number = @current_line_index.number
    message = "#{e.message} in line #{line_number}"
    @console_io.print_line(message)
    stop_running
  end

  def execute_a_statement
    line_number = @current_line_index.number
    line = @program_lines[line_number]
    statements = line.statements
    statement_index = @current_line_index.statement
    statement = statements[statement_index]
    print_trace_info(statement)
    if statement.errors.empty?
      timing = Benchmark.measure { statement.execute(self) }
      user_time = timing.utime + timing.cutime
      sys_time = timing.stime + timing.cstime
      time = user_time + sys_time
      statement.profile_time += time
      statement.profile_count += 1
    else
      stop_running
      print_errors(line_number, statement)
    end
    @get_value_seen = []
  end

  def execute_debug_command(keyword, args, cmd)
    case keyword.to_s
    when 'GO'
      @debug_done = true
    when 'STOP'
      @debug_done = true
      stop_running
    when 'STEP'
      @step_mode = true
      @debug_done = true
    when 'BREAK'
      set_breakpoints(args)
    when 'LIST'
      line_number_range = @program.line_list_spec(args)
      @program.list(line_number_range, false)
    when 'PRETTY'
      line_number_range = @program.line_list_spec(args)
      @program.pretty(line_number_range)
    when 'DELETE'
      line_number_range = @program.line_list_spec(args)
      @program.enblank(line_number_range)
    when 'PROFILE'
      line_number_range = @program.line_list_spec(args)
      @program.profile(line_number_range)
    when 'GOTO'
      statement = GotoStatement.new([keyword], [args])
      if statement.errors.empty?
        statement.execute(self)
      else
        statement.errors.each { |error| puts error }
      end
    when 'LET'
      statement = LetStatement.new([keyword], [args])
      if statement.errors.empty?
        statement.execute(self)
      else
        statement.errors.each { |error| puts error }
      end
    when 'PRINT'
      statement = PrintStatement.new([keyword], [args])
      if statement.errors.empty?
        statement.execute(self)
      else
        statement.errors.each { |error| puts error }
      end
    else
      print "Unknown command #{cmd}\n"
    end
  rescue BASICCommandError => e
    @console_io.print_line(e.to_s)
  end

  def debug_shell
    current_line_number = @current_line_index.number
    line = @program_lines[current_line_number]
    @console_io.newline_when_needed
    @console_io.print_line(current_line_number.to_s + ': ' + line.pretty(false).join(''))
    @step_mode = false
    @debug_done = false
    until @debug_done
      @console_io.print_line('DEBUG')
      cmd = @console_io.read_line

      # tokenize
      invalid_tokenbuilder = InvalidTokenBuilder.new
      tokenizer = Tokenizer.new(@tokenbuilders, invalid_tokenbuilder)
      tokens = tokenizer.tokenize(cmd)
      tokens.delete_if(&:whitespace?)

      next if tokens.empty?

      keyword = tokens[0]
      args = tokens[1..-1]

      if keyword.keyword?
        execute_debug_command(keyword, args, cmd)
      else
        print "Unknown command #{cmd}\n"
      end
    end
  end

  def program_loop
    # pick the next line number
    @next_line_index = @program.find_next_line_index(@current_line_index)
    next_line_index = nil
    next_line_index = @next_line_index.clone unless @next_line_index.nil?

    # debug shell may change @next_line_index
    current_line_number = @current_line_index.number
    current_line_index = @current_line_index.index
    if current_line_index == 0 &&
       (@step_mode || @breakpoints.key?(current_line_number))
      debug_shell
    end

    # if next line number has changed, debug_shell executed a GOTO
    if @next_line_index != next_line_index
      @current_line_index = @next_line_index
      @next_line_index = @program.find_next_line_index(@current_line_index)
    end
    
    begin
      execute_a_statement
      # set the next line number
      @current_line_index = nil
      if @running
        verify_next_line_index
        @current_line_index = @next_line_index
      end
    rescue BASICRuntimeError => e
      if @current_line_index.nil?
        @console_io.print_line(e.message)
      else
        line_number = @current_line_index.number
        @console_io.print_line("#{e.message} in line #{line_number}")
      end
      stop_running
    end
  end

  def split_breakpoint_tokens(tokens)
    tokens_lists = []

    tokens_list = []
    tokens.each do |token|
      if token.separator?
        tokens_lists << tokens_list unless tokens.empty?
        tokens_list = []
      else
        tokens_list << token
      end
    end

    tokens_lists << tokens_list unless tokens.empty?

    tokens_lists
  end

  def set_breakpoints(tokens)
    if tokens.empty?
      # print breakpoints
      bps = @breakpoints.keys.sort.map(&:to_s).join(', ')
      @console_io.print_line('BREAKPOINTS: ' + bps)
    else
      tokens_lists = split_breakpoint_tokens(tokens)
      tokens_lists.each do |tokens_list|
        if tokens_list.size == 1 &&
           tokens_list[0].numeric_constant?
          line_number = LineNumber.new(tokens_list[0])
          condition = ''
          @breakpoints[line_number] = condition
        end
        if tokens_list.size == 2 &&
           tokens_list[0].text == '-' &&
           tokens_list[1].numeric_constant?
          line_number = LineNumber.new(tokens_list[1])
          @breakpoints.delete(line_number)
        end
      end
    end
  end

  def clear_breakpoints
    @breakpoints = {}
  end

  def renumber_breakpoints(renumber_map)
    new_breakpoints = {}

    @breakpoints.each do |line_number, _|
      condition = @breakpoints[line_number]
      new_line_number = renumber_map[line_number]
      new_breakpoints[new_line_number] = condition
    end

    @breakpoints = new_breakpoints
  end

  def line_number?(line_number)
    @program_lines.key?(line_number)
  end

  def find_next_line
    @program.find_next_line(@current_line_index)
  end

  def statement_start_index(line_number, _statement_index)
    line = @program_lines[line_number]
    return if line.nil?

    statements = line.statements
    statement = statements[0]
    statement.start_index unless statement.nil?
  end

  def trace(tron_flag)
    @trace_out = (@trace_flag || tron_flag) ? @console_io : @null_out
  end

  def clear_variables
    @variables = {}
  end

  # returns an Array of values
  def evaluate(parsed_expressions, trace)
    old_trace_flag = @trace_flag
    @trace_flag = trace
    result_values = []
    parsed_expressions.each do |parsed_expression|
      stack = []
      exp = parsed_expression.empty? ? 0 : 1
      parsed_expression.each do |element|
        value = element.evaluate(self, stack, trace)
        stack.push value
      end
      act = stack.length
      raise(BASICRuntimeError, 'Bad expression') if act != exp

      next if act.zero?

      # verify each item is of correct type
      item = stack[0]
      result_values << item
    end
    @trace_flag = old_trace_flag
    result_values
  end

  def dump_vars
    @variables.each do |key, value|
      @console_io.print_line("#{key}: #{value}")
    end
    puts
  end

  def dump_user_functions
    @user_functions.each do |name, expression|
      @console_io.print_line("#{name}: #{expression}")
    end
    puts
  end

  def dump_dims
    @dimensions.each do |key, value|
      dims = []
      value.each { |nc| dims << nc.to_v }
      @console_io.print_line("#{key.class}:#{key} (#{dims.join(', ')})")
    end
  end

  def stop
    stop_running
    @console_io.print_line("STOP in line #{@current_line_index.number}")
  end

  def stop_running
    @running = false
  end

  def rand(upper_bound)
    upper_bound = upper_bound.to_v
    upper_bound = upper_bound.truncate
    upper_bound = 1 if upper_bound <= 0
    upper_bound = 1 if @ignore_rnd_arg
    upper_bound = upper_bound.to_f
    NumericConstant.new(@randomizer.rand(upper_bound))
  end

  def new_random
    @randomizer = Random.new if @respect_randomize
  end

  def find_closing_next(control_variable)
    # move to the next statement
    line_number = @current_line_index.number
    line = @program_lines[line_number]
    statements = line.statements
    statement_index = @current_line_index.statement + 1
    line_numbers = @program_lines.keys.sort
    if statement_index < statements.size
      forward_line_numbers =
        line_numbers.select { |ln| ln >= @current_line_index.number }
    else
      forward_line_numbers =
        line_numbers.select { |ln| ln > @current_line_index.number }
    end

    # search for a NEXT with the same control variable
    until forward_line_numbers.empty?
      line_number = forward_line_numbers[0]
      line = @program_lines[line_number]
      statements = line.statements
      statement_index = 0
      statements.each do |statement|
        # consider only core statements, not modifiers
        return LineNumberIndex.new(line_number, statement_index, 0) if
          statement.class.to_s == 'NextStatement' &&
          statement.control == control_variable
        statement_index += 1
      end

      forward_line_numbers.shift
    end

    raise(BASICRuntimeError, 'FOR without NEXT') # if none found, error
  end

  def set_dimensions(variable, subscripts)
    name = variable.name
    int_subscripts = normalize_subscripts(subscripts)
    @dimensions[name] = int_subscripts
  end

  def normalize_subscripts(subscripts)
    raise(Exception, 'Invalid subscripts container') unless
      subscripts.class.to_s == 'Array'
    int_subscripts = []
    subscripts.each do |subscript|
      raise(Excaption, "Invalid subscript #{subscript}") unless
        subscript.numeric_constant?
      int_subscripts << subscript.truncate
    end
    int_subscripts
  end

  def get_dimensions(variable)
    @dimensions[variable]
  end

  def set_user_function(name, variable_names, expressions)
    @user_var_names[name] = variable_names
    @user_functions[name] = expressions
  end

  def get_user_function(name)
    @user_functions[name]
  end

  def set_user_var_values(name, user_var_values)
    param_names = @user_var_names[name]
    param_names_values = param_names.zip(user_var_values)
    names_and_values = Hash[param_names_values]
    @user_var_values.push(names_and_values)
  end

  def clear_user_var_values
    @user_var_values.pop
  end

  private

  def make_dimensions(variable, count)
    if @dimensions.key?(variable)
      @dimensions[variable]
    else
      Array.new(count, NumericConstant.new(10))
    end
  end

  public

  def check_subscripts(variable, subscripts)
    int_subscripts = normalize_subscripts(subscripts)
    dimensions = make_dimensions(variable, int_subscripts.size)
    raise(BASICRuntimeError, 'Incorrect number of subscripts') if
      int_subscripts.size != dimensions.size
    int_subscripts.zip(dimensions).each do |pair|
      if pair[0] > pair[1]
        raise(BASICRuntimeError,
              "Subscript #{pair[0]} out of range #{pair[1]}")
      end
    end
  end

  def get_value(variable, trace)
    value = nil
    # first look in user function values stack
    length = @user_var_values.length
    if length > 0
      names_and_values = @user_var_values[-1]
      value = names_and_values[variable]
    end
    # then look in general table
    if value.nil?
      v = variable.to_s
      default_type = variable.content_type
      default_value = NumericConstant.new(0)
      default_value = TextConstant.new(TextConstantToken.new('""')) if
        default_type == 'TextConstant'
      unless @variables.key?(v)
        if @require_initialized
          raise(BASICRuntimeError, "Uninitialized variable #{v}")
        end
        @variables[v] = default_value
      end
      value = @variables[v]
    end
    seen = @get_value_seen.include?(variable)
    if @trace_flag && trace && !seen
      @trace_out.newline_when_needed
      # TODO: value changes to dict of value and provenence
      @trace_out.print_line(' ' + variable.to_s + ':' + value.to_s)
      @get_value_seen << variable
    end
    value
  end

  def set_value(variable, value)
    raise(BASICRuntimeError, "Cannot change locked variable #{variable}") if
      @lock_fornext && @locked_variables.include?(variable)
    
    # convert a numeric to a string when a string is expected
    if value.numeric_constant? &&
       variable.content_type == 'TextConstant'
      val = value.token_chars
      quoted_val = '"' + val + '"'
      token = TextConstantToken.new(quoted_val)
      value = TextConstant.new(token)
    end

    # convert an integer to a numeric
    if value.class.to_s == 'NumericConstant' &&
       variable.content_type == 'IntegerConstant'
      token = IntegerConstantToken.new(value.to_s)
      value = IntegerConstant.new(token)
    end

    # convert a numeric to an integer
    if value.class.to_s == 'IntegerConstant' &&
       variable.content_type == 'NumericConstant'
      token = NumericConstantToken.new(value.to_s)
      value = NumericConstant.new(token)
    end

    # check that value type matches variable type
    unless variable.compatible?(value)
      raise(BASICRuntimeError,
            "Type mismatch '#{value}' is not #{variable.content_type}")
    end

    var = variable.to_s
    @variables[var] = value
    @trace_out.newline_when_needed
    @trace_out.print_line(' ' + variable.to_s + ' = ' + value.to_s)
  end

  def set_values(name, values)
    values.each do |coords, value|
      variable = Variable.new(name, coords)
      set_value(variable, value)
    end
  end

  def lock_variable(variable)
    return unless @lock_fornext
    if @locked_variables.include?(variable)
      raise(BASICRuntimeError,
            "Attempt to lock an already locked variable #{variable}")
    end
    @locked_variables << variable
  end

  def unlock_variable(variable)
    return unless @lock_fornext
    unless @locked_variables.include?(variable)
      raise(BASICRuntimeError,
            "Attempt to unlock a variable #{variable} not locked")
    end
    @locked_variables.delete(variable)
  end

  def push_return(destination)
    @return_stack.push(destination)
  end

  def pop_return
    raise(BASICRuntimeError, 'RETURN without GOSUB') if @return_stack.empty?
    @return_stack.pop
  end

  def assign_fornext(fornext_control)
    control_variable = fornext_control.control
    @fornexts[control_variable] = fornext_control
  end

  def retrieve_fornext(control_variable)
    fornext = @fornexts[control_variable]
    raise(BASICRuntimeError, 'NEXT without FOR') if fornext.nil?
    fornext
  end

  def add_file_names(file_names)
    file_names.each do |name|
      raise(BASICRuntimeError, 'Invalid file name') unless
        name.class.to_s == 'TextConstant'
      raise(BASICRuntimeError, "File '#{name.to_v}' not found") unless
        File.file?(name.to_v)
      file_handle = FileHandle.new(@file_handlers.size + 1)
      @file_handlers[file_handle] = FileHandler.new(name.to_v)
    end
  end

  def open_file(filename, fh, mode)
    raise(BASICRuntimeError, 'Invalid file name') unless
      filename.class.to_s == 'TextConstant'
    ### todo: check for already open handle
    fhr = FileHandler.new(filename.to_v)
    fhr.set_mode(mode)
    @file_handlers[fh] = fhr
  end

  def close_file(fh)
    raise(BASICRuntimeError, 'Unknown file handle') unless
      @file_handlers.key?(fh)
    fhr = @file_handlers[fh]
    fhr.close
    ### todo: remove file handle
  end

  def get_file_handler(file_handle)
    return @console_io if file_handle.nil?

    raise(BASICRuntimeError, 'Unknown file handle') unless
      @file_handlers.key?(file_handle)
    fh = @file_handlers[file_handle]
    fh.set_mode(:print)
    fh
  end

  def get_input(file_handle)
    raise(BASICRuntimeError, 'Unknown file handle') unless
      @file_handlers.key?(file_handle)
    fh = @file_handlers[file_handle]
    fh.set_mode(:read)
    fh
  end

  def get_data_store(file_handle)
    return @data_store if file_handle.nil?
    raise(BASICRuntimeError, 'Unknown file handle') unless
      @file_handlers.key?(file_handle)
    fh = @file_handlers[file_handle]
    fh.set_mode(:read)
    fh
  end

  def int_floor?
    @int_floor
  end
end
