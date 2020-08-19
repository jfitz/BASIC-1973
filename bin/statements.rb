# Statement factory class
class StatementFactory
  include Singleton

  attr_writer :tokenbuilders

  def initialize
    @statement_definitions = statement_definitions
    @tokenbuilders = []
  end

  def parse(text)
    line_number = nil
    line = nil
    m = /\A\d+/.match(text)

    unless m.nil?
      number = NumericConstantToken.new(m[0])
      line_number = LineNumber.new(number)
      line_text = m.post_match
      all_tokens = tokenize(line_text)
      all_tokens.delete_if(&:break?)
      all_tokens.delete_if(&:whitespace?)
      comment = nil

      comment = all_tokens.pop if
        !all_tokens.empty? && all_tokens[-1].comment?

      line = create(line_text, all_tokens, comment, line_number)
    end

    [line_number, line]
  end

  def create_statement(statement_tokens)
    if statement_tokens.empty?
      statement = EmptyStatement.new
    else
      statement = nil

      keywords, tokens = extract_keywords(statement_tokens)

      while statement.nil?
        if @statement_definitions.key?(keywords)
          tokens_lists = split_keywords(tokens)

          statement =
            @statement_definitions[keywords].new(keywords, tokens_lists)
        else
          if keywords.empty?
            statement = UnknownStatement.new(text) if statement.nil?
          else
            keyword = keywords.pop
            tokens.unshift(keyword)
          end
        end
      end
    end
    statement
  end

  def create(text, all_tokens, comment, _)
    statements = []
    statements_tokens = split_on_statement_separators(all_tokens)

    if statements_tokens.empty?
      statement = EmptyStatement.new
      statements << statement
    else
      statement_index = 0
      statements_tokens.each do |statement_tokens|
        statement = UnknownStatement.new(text)

        begin
          statement = create_statement(statement_tokens)
        rescue BASICExpressionError, BASICRuntimeError => e
          statement = InvalidStatement.new(text, all_tokens, e)
        end

        statements << statement
        statement_index += 1
      end
    end

    Line.new(text, statements, all_tokens, comment)
  end

  def keywords_definitions
    keywords = []

    statement_classes.each do |cl|
      kwds = cl.lead_keywords.flatten
      kwds.each { |kwd| keywords << kwd.to_s }

      keywords += cl.extra_keywords
    end

    keywords.uniq
  end

  private

  def statement_classes
    [
      ArrInputStatement,
      ArrPrintStatement,
      ArrReadStatement,
      ArrWriteStatement,
      ArrLetStatement,
      ChainStatement,
      ChangeStatement,
      CloseStatement,
      DataStatement,
      DefineFunctionStatement,
      DimStatement,
      EndStatement,
      FilesStatement,
      FnendStatement,
      ForStatement,
      GetStatement,
      GosubStatement,
      GotoStatement,
      IfStatement,
      InputStatement,
      InputCharStatement,
      LetStatement,
      LetLessStatement,
      LineInputStatement,
      MatInputStatement,
      MatPrintStatement,
      MatReadStatement,
      MatWriteStatement,
      MatLetStatement,
      NextStatement,
      OnStatement,
      OnErrorStatement,
      OpenStatement,
      OptionStatement,
      PrintStatement,
      PrintUsingStatement,
      PutStatement,
      RandomizeStatement,
      ReadStatement,
      RecordStatement,
      RemarkStatement,
      RestoreStatement,
      ResumeStatement,
      ReturnStatement,
      RunStatement,
      SleepStatement,
      StopStatement,
      UnsaveStatement,
      WriteStatement
    ]
  end

  def statement_definitions
    lead_keywords = {}

    statement_classes.each do |class_name|
      keyword_sets = class_name.lead_keywords
      keyword_sets.each do |set|
        lead_keywords[set] = class_name
      end
    end

    lead_keywords
  end

  def split_on_statement_separators(tokens)
    tokens_lists = []
    statement_tokens = []
    tokens.each do |token|
      if token.statement_separator?
        tokens_lists << statement_tokens
        statement_tokens = []
      else
        statement_tokens << token
      end
    end
    tokens_lists << statement_tokens unless statement_tokens.empty?
    tokens_lists
  end

  def extract_keywords(all_tokens)
    keywords = []
    tokens = []
    saw_non_keyword = false

    all_tokens.each do |token|
      saw_non_keyword = true unless token.keyword?
      keywords << token unless saw_non_keyword
      tokens << token if saw_non_keyword
    end

    [keywords, tokens]
  end

  def split_keywords(tokens)
    results = []
    nonkeywords = []

    tokens.each do |token|
      if token.keyword?
        results << nonkeywords unless nonkeywords.empty?
        nonkeywords = []
        results << token
      else
        nonkeywords << token
      end
    end

    results << nonkeywords unless nonkeywords.empty?

    results
  end

  def tokenize(text)
    invalid_tokenbuilder = InvalidTokenBuilder.new
    tokenizer = Tokenizer.new(@tokenbuilders, invalid_tokenbuilder)
    tokenizer.tokenize(text)
  end
end

# parent of all statement classes
class AbstractStatement
  attr_reader :errors
  attr_reader :keywords
  attr_reader :tokens
  attr_reader :separators
  attr_reader :valid
  attr_reader :executable
  attr_reader :comment
  attr_accessor :part_of_user_function
  attr_reader :linenums
  attr_reader :autonext
  attr_reader :comprehension_effort
  attr_reader :mccabe
  attr_reader :is_if_no_else

  def self.extra_keywords
    []
  end

  def initialize(keywords, tokens_lists)
    @keywords = keywords
    @executable = true
    @tokens = tokens_lists.flatten
    @core_tokens = tokens_lists.flatten
    @separators = get_separators(@tokens)
    @errors = []
    @valid = true
    @comment = false
    @modifiers = []
    @any_if_modifiers = false
    @elements = {
      numerics: [],
      num_symbols: [],
      strings: [],
      text_symbols: [],
      variables: [],
      operators: [],
      functions: [],
      userfuncs: []
    }
    @linenums = []
    @autonext = true
    @comprehension_effort = 1
    @mccabe = 0
    @is_if_no_else = false
    @profile_count = 0
    @profile_time = 0
    @part_of_user_function = nil
  end

  private

  def extract_modifiers(tokens_lists)
    modifier_added = true
    modifier_added = make_modifier(tokens_lists) while modifier_added
    @modifiers.each do |modifier|
      @errors += modifier.errors
      @comprehension_effort += modifier.comprehension_effort
    end
    @mccabe += @modifiers.size
  end

  public

  def pretty
    list = [AbstractToken.pretty_tokens(@keywords, @tokens)]
    list.join(' ')
  end

  def pre_trace(index)
    index = -index
    index -= 1
    @modifiers[index].pre_trace
  end

  def core_trace
    list = [AbstractToken.pretty_tokens(@keywords, @core_tokens)]
    list.join(' ')
  end

  def post_trace(index)
    index -= 1
    @modifiers[index].post_trace
  end

  def dump
    ['Unimplemented']
  end

  def modifier_numerics
    nums = []
    @modifiers.each { |modifier| nums += modifier.numerics }
    nums
  end

  def modifier_num_symbols
    syms = []
    syms
  end

  def numeric_symbol_constants
    syms = @tokens.clone
    syms.keep_if(&:symbol_constant?)
    syms.keep_if(&:numeric_constant?)
  end

  def modifier_strings
    strs = []
    @modifiers.each { |modifier| strs += modifier.strings }
    strs
  end

  def modifier_text_symbols
    syms = []
    syms
  end

  def text_symbol_constants
    syms = @tokens.clone
    syms.keep_if(&:symbol_constant?)
    syms.keep_if(&:text_constant?)
  end

  def numerics
    @elements[:numerics]
  end

  def num_symbols
    @elements[:num_symbols]
  end

  def strings
    @elements[:strings]
  end

  def text_symbols
    @elements[:text_symbols]
  end

  def variables
    @elements[:variables]
  end

  def operators
    @elements[:operators]
  end

  def functions
    @elements[:functions]
  end

  def userfuncs
    @elements[:userfuncs]
  end

  def modifier_variables
    vars = []
    @modifiers.each { |modifier| vars += modifier.variables }
    vars
  end

  def modifier_operators
    opers = []
    @modifiers.each { |modifier| opers += modifier.operators }
    opers
  end

  def modifier_functions
    vars = []
    @modifiers.each { |modifier| vars += modifier.functions }
    vars
  end

  def modifier_userfuncs
    vars = []
    @modifiers.each { |modifier| vars += modifier.userfuncs }
    vars
  end

  def gotos
    []
  end

  def print_errors(console_io)
    @errors.each { |error| console_io.print_line(' ' + error) }
  end

  def program_check(_, _, _)
    true
  end

  def preexecute_a_statement(line_number, interpreter, console_io)
    if errors.empty?
      pre_execute(interpreter)
    else
      interpreter.stop_running
      console_io.print_line("Errors in line #{line_number}:")
      print_errors(console_io)
    end
    errors.empty?
  end

  private

  def get_separators(tokens)
    wanted = ['(', ')', '[', ']', ',', ';']

    separators = []

    tokens.each do |token|
      separators << token if wanted.include?(token.to_s)
    end

    separators
  end

  def pre_execute(_) end

  public

  def reset_profile_metrics
    @profile_count = 0
    @profile_time = 0
  end

  def profile(show_timing)
    text = AbstractToken.pretty_tokens(@keywords, @tokens)
    if show_timing
      timing = @profile_time.round(3).to_s
      ' (' + timing + '/' + @profile_count.to_s + ')' + text
    else
      ' (' + @profile_count.to_s + ')' + text
    end

    ### TODO: add profile for modifiers
  end

  def renumber(_) end

  private

  def execute(interpreter)
    current_line_index = interpreter.current_line_index
    index = current_line_index.index
    execute_premodifier(interpreter) if index < 0
    execute_core(interpreter) if index.zero?
    execute_postmodifier(interpreter) if index > 0
  end

  public

  def print_trace_info(trace_out, current_line_index)
    trace_out.newline_when_needed

    unless @part_of_user_function.nil?
      trace_out.print_out '(' + @part_of_user_function.to_s + ') '
    end

    index = current_line_index.index

    text = ''
    text = current_line_index.to_s + ':' + pre_trace(index) if index < 0
    text = current_line_index.to_s + ':' + core_trace if index.zero?
    text = current_line_index.to_s + ':' + post_trace(index) if index > 0

    trace_out.print_out(text)
    trace_out.newline
  end

  def execute_a_statement(interpreter, trace_out, current_line_index,
                          function_running)
    print_trace_info(trace_out, current_line_index)

    if part_of_user_function.nil? || function_running
      if @part_of_user_function != interpreter.current_user_function
        raise(BASICSyntaxError, 'Invalid transfer in/out of function')
      end

      timing = Benchmark.measure { execute(interpreter) }

      user_time = timing.utime + timing.cutime
      sys_time = timing.stime + timing.cstime
      time = user_time + sys_time

      @profile_time += time
      @profile_count += 1
    else
      trace_out.print_line(' Line ignored')
    end
  end

  def start_index
    0 - @modifiers.size
  end

  def last_index
    @modifiers.size
  end

  def multidef?
    false
  end

  def multiend?
    false
  end

  private

  def make_modifier(tokens_lists)
    template_if = ['IF', [1, '=']]

    if tokens_lists.size > 2 &&
       check_template(tokens_lists.last(2), template_if)

      # create the modifier
      modifier_tokens = tokens_lists.last
      modifier = IfModifier.new(modifier_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(2)
      @core_tokens = tokens_lists.flatten

      @any_if_modifiers = true

      return true
    end

    template_for_to = ['FOR', [1, '>='], 'TO', [1, '>=']]
    template_for_to_step = ['FOR', [1, '>='], 'TO', [1, '='], 'STEP', [1, '>=']]

    if tokens_lists.size > 4 &&
       check_template(tokens_lists.last(4), template_for_to)

      # create the modifer
      control_and_start_tokens = tokens_lists[-3]
      end_tokens = tokens_lists.last
      modifier = ForModifier.new(control_and_start_tokens, end_tokens, nil)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(4)
      @core_tokens = tokens_lists.flatten

      return true
    end

    if tokens_lists.size > 6 &&
       check_template(tokens_lists.last(6), template_for_to_step)

      # create the modifer
      control_and_start_tokens = tokens_lists[-5]
      end_tokens = tokens_lists[-3]
      step_tokens = tokens_lists.last
      modifier =
        ForModifier.new(control_and_start_tokens, end_tokens, step_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(6)
      @core_tokens = tokens_lists.flatten

      return true
    end

    false
  end

  def execute_premodifier(interpreter)
    current_line_index = interpreter.current_line_index
    index = 0 - (current_line_index.index + 1)
    modifier = @modifiers[index]
    modifier.execute_pre(interpreter)
  end

  def execute_postmodifier(interpreter)
    current_line_index = interpreter.current_line_index
    index = current_line_index.index - 1
    modifier = @modifiers[index]
    modifier.execute_post(interpreter)
  end

  protected

  def check_template(tokens_lists, template)
    return false unless tokens_lists.size == template.size

    result = true
    pairs = template.zip(tokens_lists)

    pairs.each do |pair|
      control = pair[0]
      value = pair[1]

      if control.class.to_s == 'Array' &&
         value.class.to_s == 'Array'

        # control array and value array implies an expression
        result &= value.size == control[0] if control.size == 1

        result &= value.size >= control[0] if
          control.size == 2 && control[1] == '>='

      elsif control.class.to_s == 'Array' &&
            value.class.to_s == 'KeywordToken'

        # control array and single value (not array of one) implies
        # multiple possible keywords
        result &= control.include?(value.to_s)

      elsif control.class.to_s == 'String' &&
            value.class.to_s == 'KeywordToken'

        # single control and single value is a specific keyword
        result &= value.to_s == control

      else
        result = false
      end
    end

    result
  end

  def split_tokens(tokens, want_separators)
    lists = []
    list = []
    parens_level = 0

    tokens.each do |token|
      if token.operand? &&
         (!list.empty? && (list[-1].operand? || list[-1].groupend?))
        lists << list unless list.empty?
        list = [token]
      elsif token.separator? && parens_level.zero?
        lists << list unless list.empty?
        lists << token if want_separators
        list = []
      else
        list << token
      end

      parens_level += 1 if token.groupstart?
      parens_level -= 1 if token.groupend? && !parens_level.zero?
    end

    lists << list unless list.empty?
    lists
  end

  def split_on_token(tokens, token_to_split)
    results = []
    list = []

    tokens.each do |token|
      if token.to_s != token_to_split
        list << token
      else
        results << list unless list.empty?
        list = []
        results << token
      end
    end

    results << list unless list.empty?

    results
  end

  def split_keywords(tokens)
    results = []
    nonkeywords = []

    tokens.each do |token|
      if token.keyword?
        results << nonkeywords unless nonkeywords.empty?
        nonkeywords = []
        results << token
      else
        nonkeywords << token
      end
    end

    results << nonkeywords unless nonkeywords.empty?

    results
  end

  def make_references(items, exp1 = nil, exp2 = nil)
    numerics = []
    num_symbols = []
    strings = []
    text_symbols = []
    variables = []
    operators = []
    functions = []
    userfuncs = []

    unless exp1.nil?
      numerics += exp1.numerics
      x1 = exp1.num_symbols
      num_symbols += x1
      strings += exp1.strings
      text_symbols += exp1.text_symbols
      variables += exp1.variables
      operators += exp1.operators
      functions += exp1.functions
      userfuncs += exp1.userfuncs
    end

    unless exp2.nil?
      numerics += exp2.numerics
      num_symbols += exp2.num_symbols
      strings += exp2.strings
      text_symbols += exp2.text_symbols
      variables += exp2.variables
      operators += exp2.operators
      functions += exp2.functions
      userfuncs += exp2.userfuncs
    end

    unless items.nil?
      items.each { |item| numerics += item.numerics }
      items.each { |item| num_symbols += item.num_symbols }
      items.each { |item| strings += item.strings }
      items.each { |item| text_symbols += item.text_symbols }
      items.each { |item| variables += item.variables }
      items.each { |item| operators += item.operators }
      items.each { |item| functions += item.functions }
      items.each { |item| userfuncs += item.userfuncs }
    end

    {
      numerics: numerics,
      num_symbols: num_symbols,
      strings: strings,
      text_symbols: text_symbols,
      variables: variables,
      operators: operators,
      functions: functions,
      userfuncs: userfuncs
    }
  end
end

# unparsed statement
class InvalidStatement < AbstractStatement
  def initialize(text, all_tokens, error)
    super([], all_tokens)

    @valid = false
    @executable = false
    @text = text
    @errors << 'Invalid statement: ' + error.message
  end

  def to_s
    @text
  end

  def pre_execute(_)
    raise(BASICSyntaxError, @errors[0])
  end

  def execute_core(_)
    raise(BASICSyntaxError, @errors[0])
  end
end

# unknown statement
class UnknownStatement < AbstractStatement
  def initialize(text)
    super([], [])

    @valid = false
    @executable = false
    @text = text
    @errors << "Unknown statement '#{text.strip}'"
  end

  def to_s
    @text
  end

  def execute_core(_) end
end

# empty statement (line number only)
class EmptyStatement < AbstractStatement
  def initialize
    super([], [])

    @valid = false
    @executable = false
    @comprehension_effort = 0
  end

  def dump
    []
  end

  def to_s
    ''
  end

  def execute_core(_) end
end

# REMARK
class RemarkStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('REMARK')],
      [KeywordToken.new('REM')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    @valid = false
    @comment = true
    @executable = false
    @rest = Remark.new(nil)
    @rest = Remark.new(tokens_lists[0]) unless tokens_lists.empty?
  end

  def dump
    lines = [@rest.dump]

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(_) end
end

# common functions for IO statements
module FileFunctions
  def extract_file_handle(items)
    file_tokens = nil

    unless items.empty? ||
           items[0].carriage_control?

      candidate_file_tokens = items[0]

      if candidate_file_tokens.filehandle?
        file_tokens = items.shift

        items.shift if
          !items.empty? &&
          items[0].carriage_control?
      end
    end

    file_tokens
  end

  def get_file_handle(interpreter, file_tokens)
    return nil if file_tokens.nil?

    file_handles = file_tokens.evaluate(interpreter)
    FileHandle.new(file_handles[0])
  end

  def add_needed_value(items, shape)
    items << ValueExpression.new([], shape) if
      items.empty? || !items[-1].printable?
  end

  def add_needed_carriage(items)
    items << CarriageControl.new('') if !items.empty? && items[-1].printable?
  end

  def add_final_carriage(items, final)
    items << final if !items.empty? && items[-1].printable?
  end

  def add_default_value_carriage(items, shape)
    return unless items.empty?

    add_needed_value(items, shape)
    add_final_carriage(items, CarriageControl.new('NL'))
  end

  def dump
    lines = []

    lines += @file_tokens.dump unless @file_tokens.nil?
    @items.each { |item| lines += item.dump } unless @items.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end
end

# common functions for INPUT statements
module InputFunctions
  def extract_prompt(items)
    prompt = nil

    unless items.empty? ||
           items[0].carriage_control?

      candidate_prompt_tokens = items[0]

      if candidate_prompt_tokens.text_constant?
        prompt = items.shift

        items.shift if
          !items.empty? &&
          items[0].carriage_control?
      end
    end

    prompt
  end

  def tokens_to_expressions(tokens_lists, shape)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape)
      end
    end

    items
  end

  def add_expression(items, tokens, shape)
    if tokens[0].operator? && tokens[0].pound?
      items << ValueExpression.new(tokens, :scalar)
    elsif tokens[0].text_constant?
      items << ValueExpression.new(tokens, :scalar)
    else
      items << TargetExpression.new(tokens, shape)
    end
  rescue BASICExpressionError
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" is not a value or operator'
  end

  def zip(names, values)
    raise BASICRuntimeError.new('Too few items', 112) if
      values.size < names.size

    results = []
    (0...names.size).each do |i|
      results << { 'name' => names[i], 'value' => values[i] }
    end

    results
  end

  def input_values(fhr, interpreter, prompt, count)
    values = []

    while values.size < count
      remaining = count - values.size
      fhr.prompt(prompt, remaining)
      values += fhr.input(interpreter)

      prompt = nil
    end

    values
  end

  def file_values(fhr, interpreter)
    values = []

    values += fhr.input(interpreter)

    values
  end
end

# common functions for PRINT statements
module PrintFunctions
  def tokens_to_expressions(tokens_lists, shape)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape)
      elsif tokens_list.separator?
        add_needed_value(items, shape)
        items << CarriageControl.new(tokens_list.to_s)
      end
    end

    add_final_carriage(items, CarriageControl.new('NL'))
    add_default_value_carriage(items, shape)
    items
  end

  def add_expression(items, tokens, shape)
    if tokens[0].operator? && tokens[0].pound?
      items << ValueExpression.new(tokens, :scalar)
    else
      add_needed_carriage(items)
      items << ValueExpression.new(tokens, shape)
    end
  rescue BASICExpressionError
    line_text = tokens.map(&:to_s).join

    @errors <<
      'Syntax error: "' + line_text + '" is not a value or operator'
  end
end

# common functions for READ statements
module ReadFunctions
  def tokens_to_expressions(tokens_lists, shape)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape)
      end
    end

    items
  end

  def add_expression(items, tokens, shape)
    if tokens[0].operator? && tokens[0].pound?
      items << ValueExpression.new(tokens, :scalar)
    else
      items << TargetExpression.new(tokens, shape)
    end
  rescue BASICExpressionError
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" is not a value or operator'
  end
end

# common functions for WRITE statements
module WriteFunctions
  def tokens_to_expressions(tokens_lists, shape)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape)
      elsif tokens_list.separator?
        add_needed_value(items, shape)
        items << CarriageControl.new(tokens_list.to_s)
      end
    end

    add_final_carriage(items, CarriageControl.new('NL'))
    add_default_value_carriage(items, shape)
    items
  end

  def add_expression(items, tokens, shape)
    if tokens[0].operator? && tokens[0].pound?
      items << ValueExpression.new(tokens, :scalar)
    else
      add_needed_carriage(items)
      items << ValueExpression.new(tokens, shape)
    end
  rescue BASICExpressionError
    line_text = tokens.map(&:to_s).join

    @errors <<
      'Syntax error: "' + line_text + '" is not a value or operator'
  end
end

# CHAIN
class ChainStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('CHAIN')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)
    @autonext = false unless @any_if_modifiers

    template = [[1, '>']]

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)

    target_tokens = tokens_lists[0]
    @target = ValueExpression.new(target_tokens, :scalar)
    @elements = make_references(nil, @target)
    @comprehension_effort += @target.comprehension_effort
  end

  def dump
    lines = ['']

    lines += @target.dump

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    target_values = @target.evaluate(interpreter)
    target_value = target_values[0]

    raise(BASICExpressionError, 'Target must be text item.') unless
      target_value.text_constant?

    text = target_value.value

    # 'DEMON' is a special case
    if text.rstrip == 'DEMON'
      io = interpreter.console_io
      io.newline_when_needed
      interpreter.stop
    else
      interpreter.chain(target_values)
    end
  end
end

# CHANGE
class ChangeStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('CHANGE')],
      [KeywordToken.new('CHA')]
    ]
  end

  def self.extra_keywords
    ['TO']
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>='], 'TO', [1, '=']]

    if check_template(tokens_lists, template)
      source_tokens = tokens_lists[0]
      target_tokens = tokens_lists[2]

      source = ValueExpression.new(source_tokens, :scalar)

      case source.content_type
      when :string
        # string to array
        @source = ValueExpression.new(source_tokens, :scalar)
        @target = TargetExpression.new(target_tokens, :array)
      when :numeric
        # array to string
        @source = ValueExpression.new(source_tokens, :array)
        @target = TargetExpression.new(target_tokens, :scalar)
      else
        raise BASICExpressionError, 'Type mismatch'
      end

      @elements = make_references(nil, @source, @target)
      @comprehension_effort += @source.comprehension_effort
      @comprehension_effort += @target.comprehension_effort
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    lines += @source.dump unless @source.nil?
    lines += @target.dump unless @target.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    source_values = @source.evaluate(interpreter)
    source_value = source_values[0]

    if source_value.text_constant?
      # string to array

      array = source_value.unpack
      dims = array.dimensions
      values = array.values(interpreter)

      target_token = VariableToken.new(@target.to_s)
      target_name = VariableName.new(target_token)
      target = Variable.new(target_name, :scalar, [])
      target.valref = :reference

      interpreter.set_dimensions(target, dims)
      interpreter.set_values(target_name, values)

    elsif source_value.numeric_constant?
      # array to string
      source_variable_token = VariableToken.new(@source.to_s)
      source_variable_name = VariableName.new(source_variable_token)

      target_values = @target.evaluate(interpreter)
      target = target_values[0]

      dims = interpreter.get_dimensions(source_variable_name)

      raise(BASICSyntaxError, 'Source not an array') if dims.nil?

      raise(BASICSyntaxError, 'Source must have 1 dimension') unless
        dims.size == 1

      cols = dims[0].to_i
      values = {}
      (0..cols).each do |col|
        column = IntegerConstant.new(col)
        variable = Variable.new(source_variable_name, :scalar, [column])
        coord = AbstractElement.make_coord(col)
        values[coord] = interpreter.get_value(variable)
      end
      array = BASICArray.new(dims, values)
      text = array.pack

      interpreter.set_value(target, text)

    else
      raise BASICExpressionError, 'Type mismatch'
    end
  end
end

# CLOSE
class CloseStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('CLOSE')],
      [KeywordToken.new('CLO')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]
    template_file = ['FILE', [1, '>=']]

    @filenum_expression = []
    if check_template(tokens_lists, template) ||
       check_template(tokens_lists, template_file)
      @filenum_expression = ValueExpression.new(tokens_lists[-1], :scalar)

      @elements = make_references(nil, @filenum_expression)
      @comprehension_effort += @filenum_expression.comprehension_effort
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = @filenum_expression.dump

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    fns = @filenum_expression.evaluate(interpreter)
    fh = FileHandle.new(fns[0])
    interpreter.close_file(fh)
  end
end

# DATA
class DataStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('DATA')],
      [KeywordToken.new('DAT')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    @executable = false

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      @expressions = ValueExpression.new(tokens_lists[0], :scalar)
      @elements = make_references(nil, @expressions)
      @comprehension_effort += @expressions.comprehension_effort
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = @expressions.dump

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def pre_execute(interpreter)
    ds = interpreter.get_data_store(nil)
    data_list = @expressions.evaluate(interpreter)
    ds.store(data_list)
  end

  def execute_core(_) end
end

# DEF FNx
class DefineFunctionStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('DEF')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      @definition = nil

      begin
        @definition = UserFunctionDefinition.new(tokens_lists[0])
        @elements = make_references(nil, @definition)
        @comprehension_effort += @definition.comprehension_effort
      rescue BASICExpressionError => e
        @errors << e.message
      end
    else
      @errors << 'Syntax error'
    end
  end

  def multidef?
    return false if @definition.nil?

    @definition.multidef?
  end

  def function_name
    @definition.name
  end

  def dump
    lines = []

    lines += @definition.dump unless
      @definition.nil? || @definition.multidef?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def pre_execute(interpreter)
    name = @definition.name
    signature = @definition.sig
    interpreter.set_user_function(name, signature, @definition)
  end

  def execute_core(_) end
end

# DIM
class DimStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('DIM')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    template = [[1, '>=']]

    @expressions = []
    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], false)

      tokens_lists.each do |tokens_list|
        begin
          @expressions << DeclarationExpression.new(tokens_list)
        rescue BASICExpressionError
          @errors << 'Invalid variable ' + tokens_list.map(&:to_s).join
        end
        @expressions.each do |expression|
          @comprehension_effort += expression.comprehension_effort
        end
      end
    else
      @errors << 'Syntax error'
    end

    @elements = make_references(@expressions)
  end

  def dump
    lines = []

    @expressions.each { |expression| lines += expression.dump }

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    @expressions.each do |expression|
      variables = expression.evaluate(interpreter)
      variable = variables[0]
      subscripts = variable.subscripts

      if subscripts.empty?
        raise BASICSyntaxError, 'DIM statement requires subscript range'
      end

      interpreter.set_dimensions(variable, subscripts)
    end
  end
end

# END
class EndStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('END')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    @autonext = false
    @executable = false

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def program_check(program, console_io, line_number_index)
    next_line = program.find_next_line_index(line_number_index)
    return true if next_line.nil?
    console_io.print_line("Statements after END in line #{line_number_index}")

    false
  end

  def execute_core(interpreter)
    io = interpreter.console_io
    io.newline_when_needed
    interpreter.stop
  end
end

# FILES
class FilesStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('FILES')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      @expressions = ValueExpression.new(tokens_lists[0], :scalar)
      @elements = make_references(nil, @expressions)
      @comprehension_effort += @expressions.comprehension_effort
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    @expressions.dump unless @expressions.nil?
  end

  def pre_execute(interpreter)
    file_names = @expressions.evaluate(interpreter)
    interpreter.add_file_names(file_names)
  rescue BASICRuntimeError => e
    raise BASICPreexecuteError.new(e.message, e.code)
  end

  def execute_core(_) end
end

# FNEND
class FnendStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('FNEND')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def multiend?
    true
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    interpreter.exit_user_function
  end
end

# FOR statement
class ForStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('FOR')]
    ]
  end

  def self.extra_keywords
    %w[TO STEP]
  end

  def initialize(keywords, tokens_lists)
    super

    template1 = [[1, '>='], 'TO', [1, '>=']]
    template2 = [[1, '>='], 'TO', [1, '>='], 'STEP', [1, '>=']]

    if check_template(tokens_lists, template1)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        variable_name = VariableName.new(tokens1[0])
        @control = Variable.new(variable_name, :scalar, [])
        @start = ValueExpression.new(tokens2, :scalar)
        @end = ValueExpression.new(tokens_lists[2], :scalar)
        @step = nil
        @elements[:numerics] = @start.numerics + @end.numerics
        @elements[:num_symbols] = @start.num_symbols + @end.num_symbols
        @elements[:strings] = @start.strings + @end.strings
        @elements[:text_symbols] = @start.text_symbols + @end.text_symbols

        control = XrefEntry.new(@control.to_s, nil, true)

        @elements[:variables] =
          [control] + @start.variables + @end.variables

        @elements[:operators] =
          @start.operators + @end.operators

        @elements[:functions] =
          @start.functions + @end.functions

        @elements[:userfuncs] =
          @start.userfuncs + @end.userfuncs

        @comprehension_effort += @start.comprehension_effort
        @comprehension_effort += @end.comprehension_effort
        @mccabe += 1
      rescue BASICExpressionError => e
        @errors << e.message
      end
    elsif check_template(tokens_lists, template2)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        variable_name = VariableName.new(tokens1[0])
        @control = Variable.new(variable_name, :scalar, [])
        @start = ValueExpression.new(tokens2, :scalar)
        @end = ValueExpression.new(tokens_lists[2], :scalar)
        @step = ValueExpression.new(tokens_lists[4], :scalar)

        @elements[:numerics] =
          @start.numerics + @end.numerics + @step.numerics

        @elements[:num_symbols] =
          @start.num_symbols + @end.num_symbols + @step.num_symbols

        @elements[:strings] =
          @start.strings + @end.strings + @step.strings

        @elements[:text_symbols] =
          @start.text_symbols + @end.text_symbols + @end.text_symbols

        control = XrefEntry.new(@control.to_s, nil, true)

        @elements[:variables] =
          [control] + @start.variables + @end.variables + @step.variables

        @elements[:operators] =
          @start.operators + @end.operators + @step.operators

        @elements[:functions] =
          @start.functions + @end.functions + @step.functions

        @elements[:userfuncs] =
          @start.userfuncs + @end.userfuncs + @step.userfuncs

        @comprehension_effort += @start.comprehension_effort
        @comprehension_effort += @end.comprehension_effort
        @comprehension_effort += @step.comprehension_effort
        @mccabe += 1
      rescue BASICExpressionError => e
        @errors << e.message
      end
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    lines << 'control: ' + @control.dump unless @control.nil?
    lines << 'start:   ' + @start.dump.to_s unless @start.nil?
    lines << 'end:     ' + @end.dump.to_s unless @end.nil?
    lines << 'step:    ' + @step.dump.to_s unless @step.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    from = @start.evaluate(interpreter)[0]
    to = @end.evaluate(interpreter)[0]
    step = NumericConstant.new(1)
    step = @step.evaluate(interpreter)[0] unless @step.nil?

    fornext_control = interpreter.assign_fornext(@control, from, to, step)
    interpreter.lock_variable(@control)
    interpreter.enter_fornext(@control)
    terminated = fornext_control.front_terminated?

    if terminated
      interpreter.next_line_index = interpreter.find_closing_next(@control)
      interpreter.unlock_variable(@control)
      interpreter.exit_fornext
    end

    io = interpreter.trace_out
    print_more_trace_info(io, from, to, step, terminated)
  end

  private

  def control_and_start(tokens)
    parts = split_on_token(tokens, '=')
    raise(BASICExpressionError, 'Incorrect initialization') if
      parts.size != 3
    raise(BASICExpressionError, 'Incorrect initialization') if
      parts[1].to_s != '='

    @errors << 'Control variable must be a variable' unless
      parts[0][0].variable?

    [parts[0], parts[2]]
  end

  def print_more_trace_info(io, from, to, step, terminated)
    io.trace_output(" #{@start} = #{from}") unless @start.numeric_constant?
    io.trace_output(" #{@end} = #{to}") unless @end.numeric_constant?
    io.trace_output(" #{@step} = #{step}") unless
      @step.nil? || @step.numeric_constant?
    io.trace_output(" terminated:#{terminated}")
  end
end

# GET
class GetStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('GET')]
    ]
  end

  include FileFunctions
  include InputFunctions
  
  def initialize(keywords, tokens_lists)
    super

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      if items.size == 3
        line_no = items[1]
        if line_no.empty?
          @errors << 'No line number'
        else
          line_num = line_no[0]
          begin
            @line_number = LineNumber.new(line_num)
          rescue BASICSyntaxError => e
            @errors << e.message
          end
        end
      else
        @errors << 'Syntax error'
      end

      @items = tokens_to_expressions(items, :scalar)

      @elements = make_references(@items)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []
    @items.each { |item| lines += item.dump }
    lines
  end

  def program_check(program, console_io, line_number_index)
    retval = true

    unless program.line_number?(@line_number)
      console_io.print_line(
        "Line number #{@line_number} not found in line #{line_number_index}"
      )
      retval = false
    end

    retval
  end

  def execute_core(interpreter)
    file_no = @items[0]
    fh = get_file_handle(interpreter, file_no)
    fhr = interpreter.get_file_handler(fh, :memory)

    rec_no = @items[2]
    rec_num = rec_no.evaluate(interpreter)
    rec_number = rec_num[0].to_i

    read_items = interpreter.get_record_read_variables(@line_number)

    item_names = []
    read_items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        item_names << target
      end
    end

    # always from file, never from console
    values = fhr.read_record(interpreter, rec_number)

    raise BASICRuntimeError.new('Not enough values', 112) if
      values.size < item_names.size

    name_value_pairs =
      zip(item_names, values[0..item_names.length])

    name_value_pairs.each do |hash|
      variable = hash['name']
      value = hash['value']
      interpreter.set_value(variable, value)
    end

    interpreter.clear_previous_lines
  end

  def renumber(renumber_map)
    @line_number = renumber_map[@line_number]
    @token_index = -1
    i = 0
    num_commas = 1
    @tokens.each do |token|
      @token_index = i if token.numeric_constant? && num_commas == 1

      num_commas += 1 if token.separator?

      i += 1
    end
    @tokens[@token_index] = NumericConstantToken.new(@line_number.line_number)
  end

  private

  def tokens_to_expressions(tokens_lists, shape)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape)
      end
    end

    items
  end

  def add_expression(items, tokens, shape)
    items << ValueExpression.new(tokens, shape)
  rescue BASICExpressionError
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" is not a value or operator'
  end
end

# GOSUB
class GosubStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('GOSUB')],
      [KeywordToken.new('GOS')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1]]

    if check_template(tokens_lists, template)
      if tokens_lists[0][0].numeric_constant?
        @destination = LineNumber.new(tokens_lists[0][0])
        @linenums = [@destination]
      else
        @errors << "Invalid line number #{tokens_lists[0][0]}"
      end
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = [@destination.dump]

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def gotos
    [@destination]
  end

  def program_check(program, console_io, line_number_index)
    return true if program.line_number?(@destination)
    console_io.print_line(
      "Line number #{@destination} not found in line #{line_number_index}"
    )
    false
  end

  def execute_core(interpreter)
    line_number = @destination
    index = interpreter.statement_start_index(line_number, 0)
    raise(BASICSyntaxError, 'Line number not found') if index.nil?
    destination = LineNumberIndex.new(line_number, 0, index)
    interpreter.push_return(interpreter.next_line_index)
    interpreter.next_line_index = destination
  end

  def renumber(renumber_map)
    @destination = renumber_map[@destination]
    @linenums = [@destination]
    @tokens[-1] = NumericConstantToken.new(@destination.line_number)
  end
end

# GOTO
class GotoStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('GOTO')],
      [KeywordToken.new('GOT')]
    ]
  end

  def self.extra_keywords
    ['OF']
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)
    @autonext = false unless @any_if_modifiers

    template1 = [[1]]
    template2 = [[1, '>='], 'OF', [1, '>=']]
    @destination = nil
    @destinations = nil
    @expression = nil

    if check_template(tokens_lists, template1)
      if tokens_lists[0][0].numeric_constant?
        @destination = LineNumber.new(tokens_lists[0][0])
        @linenums = [@destination]
      else
        @errors << "Invalid line number #{tokens_lists[0][0]}"
      end
    elsif check_template(tokens_lists, template2)
      expression = tokens_lists[0]

      begin
        @expression = ValueExpression.new(expression, :scalar)
        @elements = make_references(nil, @expression)
        @comprehension_effort += @expression.comprehension_effort
      rescue BASICExpressionError => e
        @errors << e.message
      end

      destinations = tokens_lists[2]
      line_nums = split_tokens(destinations, false)
      @destinations = []

      line_nums.each do |line_num|
        if line_num.size == 1
          destination = line_num[0]
          if destination.numeric_constant?
            @destinations << LineNumber.new(destination)
          else
            @errors << "Invalid line number #{destination}"
          end
        else
          @errors << "Invalid line specification #{line_num}"
        end
      end

      @linenums = @destinations
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    lines << @destination.dump unless @destination.nil?
    lines += @expression.dump unless @expression.nil?

    unless @destinations.nil?
      @destinations.each { |destination| lines << destination.dump }
    end

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def gotos
    return [@destination] unless @destination.nil?
    @destinations
  end

  def program_check(program, console_io, line_number_index)
    retval = true

    unless @destination.nil? || program.line_number?(@destination)
      console_io.print_line(
        "Line number #{@destination} not found in line #{line_number_index}"
      )
      retval = false
    end

    unless @destinations.nil?
      @destinations.each do |destination|
        next if program.line_number?(destination)

        console_io.print_line(
          "Line number #{destination} not found in line #{line_number_index}"
        )
        retval = false
      end
    end

    retval
  end

  def execute_core(interpreter)
    unless @destination.nil?
      line_number = @destination
      index = interpreter.statement_start_index(line_number, 0)
      raise(BASICSyntaxError, 'Line number not found') if index.nil?
      destination = LineNumberIndex.new(line_number, 0, index)
      interpreter.next_line_index = destination
    end

    unless @destinations.nil?
      values = @expression.evaluate(interpreter)

      raise(BASICExpressionError, 'Expecting one value') unless values.size == 1

      value = values[0]

      raise(BASICSyntaxError, 'Invalid value') unless
        value.numeric_constant?

      io = interpreter.trace_out
      io.trace_output(' ' + @expression.to_s + ' = ' + value.to_s)
      index = value.to_i

      raise BASICRuntimeError.new('Index out of range', 129) if
        index < 1 || index > @destinations.size

      # get destination in list
      line_number = @destinations[index - 1]
      index = interpreter.statement_start_index(line_number, 0)

      raise(BASICSyntaxError, 'Line number not found') if index.nil?

      destination = LineNumberIndex.new(line_number, 0, index)
      interpreter.next_line_index = destination
    end
  end

  def renumber(renumber_map)
    unless @destination.nil?
      @destination = renumber_map[@destination]
      @linenums = [@destination]
      @tokens[-1] = NumericConstantToken.new(@destination.line_number)
    end

    return if @destinations.nil?

    new_destinations = []
    @destinations.each do |destination|
      new_destinations << renumber_map[destination]
    end

    i = 0
    index = 0
    @tokens.each do |token|
      index = i if token.to_s == 'OF'
      i += 1
    end

    new_destinations.each do |destination|
      @tokens[index + 1] =
        NumericConstantToken.new(destination.line_number)

      index += 2
    end

    @destinations = new_destinations
    @linenums = @destinations
  end
end

# common functions for IF statements
class AbstractIfStatement < AbstractStatement
  def initialize(keywords, tokens_lists)
    super

    if tokens_lists.class.to_s == 'Hash'
      @expression = parse_expression(tokens_lists['expr'])
      @destination, @statement = parse_target(tokens_lists['then'])
      @else_dest = nil
      @else_dest, @else_stmt = parse_target(tokens_lists['else']) if
        tokens_lists.key?('else')

      @elements[:numerics] = make_numeric_references
      @elements[:num_symbols] = make_num_symbol_references
      @elements[:strings] = make_string_references
      @elements[:text_symbols] = make_text_symbol_references
      @elements[:variables] = make_variable_references
      @elements[:operators] = make_operator_references
      @elements[:functions] = make_function_references
      @elements[:userfuncs] = make_userfunc_references
      @linenums = make_linenum_references
    else
      begin
        stack = parse_if(tokens_lists)
        @expression = parse_expression(stack['expr'])
        @destination, @statement = parse_target(stack['then'])
        @else_dest = nil
        @else_dest, @else_stmt = parse_target(stack['else']) if
          stack.key?('else')

        @elements[:numerics] = make_numeric_references
        @elements[:num_symbols] = make_num_symbol_references
        @elements[:strings] = make_string_references
        @elements[:text_symbols] = make_text_symbol_references
        @elements[:variables] = make_variable_references
        @elements[:operators] = make_operator_references
        @elements[:functions] = make_function_references
        @elements[:userfuncs] = make_userfunc_references
        @linenums = make_linenum_references
      rescue BASICExpressionError => e
        @errors << 'Syntax Error: ' + e.message
      end
    end

    @comprehension_effort += @statement.comprehension_effort unless @statement.nil?
    @comprehension_effort += @else_stmt.comprehension_effort unless @else_stmt.nil?

    @mccabe += 1
    @mccabe += @statement.mccabe unless @statement.nil?
    @mccabe += @else_stmt.mccabe unless @else_stmt.nil?

    @is_if_no_else = @else_dest.nil? && @else_stmt.nil?
  end

  private

  def parse_if(tokens_lists)
    stack = []
    new_dict = { 'expr' => [], 'then' => [] }
    stack << new_dict
    dict = stack[-1]
    state = 1

    tokens_lists.each do |tokens_list|
      handled = false
      case state
      when 1
        if tokens_list == 'THEN'
          state = 2
        elsif tokens_list.class.to_s == 'KeywordToken'
          if tokens_list.to_s == 'GOTO'
            state = 4
          else
            dict['expr'] << tokens_list
          end
        else
          dict['expr'] += tokens_list
        end
        handled = true
      when 2
        unless handled
          if tokens_list == 'ELSE'
            dict['else'] = []
            state = 3
          elsif tokens_list == 'IF' && dict['then'].empty?
            new_dict = { 'expr' => [], 'then' => [] }
            dict['then'] = new_dict
            stack << new_dict
            dict = stack[-1]
            state = 1
          elsif tokens_list.class.to_s == 'KeywordToken'
            dict['then'] << tokens_list
          else
            dict['then'] += tokens_list
          end
          handled = true
        end
      when 3
        unless handled
          if tokens_list == 'ELSE'
            stack.pop
            # TODO: exit if stack.empty
            dict = stack[-1]
            dict['else'] = []
          elsif tokens_list == 'IF' && dict['else'].empty?
            new_dict = { 'expr' => [], 'then' => [] }
            dict['else'] = new_dict
            stack << new_dict
            dict = stack[-1]
            state = 1
          elsif tokens_list.class.to_s == 'KeywordToken'
            dict['else'] << tokens_list
          else
            dict['else'] += tokens_list
          end
          handled = true
        end
      when 4
        unless handled
          if dict['then'].empty?
            dict['then'] += tokens_list
          else
            raise(BASICSyntaxError, 'THEN without matching IF')
          end
          handled = true
        end
      end
    end

    stack[0]
  end

  def print_dict(dict)
    expr_s = '['
    x0 = dict['expr']

    x0.each do |x|
      if x.class.to_s == 'Array'
        expr_s += '[' + x.map(&:to_s).join(', ') + ']'
      else
        expr_s += x.to_s
      end
      expr_s += ', '
    end

    expr_s += ']'
    x1 = dict['then']

    if x1.class.to_s == 'Array'
      ax1 = []
      x1.each do |x|
        if x.class.to_s == 'Array'
          ax1 << '[' + x.map(&:to_s).join(', ') + ']'
        else
          ax1 << x.to_s
        end
      end
      then_s = '[' + ax1.join(', ') + ']'
    else
      then_s = 'DICT'
    end

    else_s = ''

    if dict.key?('else')
      x2 = dict['else']
      if x2.class.to_s == 'Array'
        ax2 = []
        x2.each do |x|
          if x.class.to_s == 'Array'
            ax2 << '[' + x.map(&:to_s).join(', ') + ']'
          else
            ax2 << x.to_s
          end
        end
        else_s = '[' + ax2.join(', ') + ']'
      else
        else_s = 'DICT'
      end
    end
  end

  def make_numeric_references
    nums = []
    nums += @expression.numerics unless @expression.nil?
    nums += @statement.numerics unless @statement.nil?
    nums += @else_stmt.numerics unless @else_stmt.nil?
    nums
  end

  def make_num_symbol_references
    nums = []
    nums += @expression.num_symbols unless @expression.nil?
    nums += @statement.num_symbols unless @statement.nil?
    nums += @else_stmt.num_symbols unless @else_stmt.nil?
    nums
  end

  def make_string_references
    strs = []
    strs += @expression.strings unless @expression.nil?
    strs += @statement.strings unless @statement.nil?
    strs += @else_stmt.strings unless @else_stmt.nil?
    strs
  end

  def make_text_symbol_references
    strs = []
    strs += @expression.text_symbols unless @expression.nil?
    strs += @statement.text_symbols unless @statement.nil?
    strs += @else_stmt.text_symbols unless @else_stmt.nil?
    strs
  end

  def make_variable_references
    vars = []
    vars += @expression.variables unless @expression.nil?
    vars += @statement.variables unless @statement.nil?
    vars += @else_stmt.variables unless @else_stmt.nil?
    vars
  end

  def make_operator_references
    vars = []
    vars += @expression.operators unless @expression.nil?
    vars += @statement.operators unless @statement.nil?
    vars += @else_stmt.operators unless @else_stmt.nil?
    vars
  end

  def make_function_references
    vars = []
    vars += @expression.functions unless @expression.nil?
    vars += @statement.functions unless @statement.nil?
    vars += @else_stmt.functions unless @else_stmt.nil?
    vars
  end

  def make_userfunc_references
    vars = []
    vars += @expression.userfuncs unless @expression.nil?
    vars += @statement.userfuncs unless @statement.nil?
    vars += @else_stmt.userfuncs unless @else_stmt.nil?
    vars
  end

  def make_linenum_references
    nums = []
    nums << @destination unless @destination.nil?
    nums << @else_dest unless @else_dest.nil?
    nums
  end

  public

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?
    lines += @statement.dump unless @statement.nil?
    lines += @else_stmt.dump unless @else_stmt.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def gotos
    destinations = []

    destinations << @destination unless @destination.nil?
    destinations += @statement.gotos unless @statement.nil?
    destinations << @else_dest unless @else_dest.nil?
    destinations += @else_stmt.gotos unless @else_stmt.nil?

    destinations
  end

  def program_check(program, console_io, line_number_index)
    retval = true

    if @destination.nil? && @statement.nil?
      console_io.print_line(
        "Invalid or missing line number in line #{line_number}"
      )
    end

    unless @destination.nil? || program.line_number?(@destination)
      console_io.print_line(
        "Line number #{@destination} not found in line #{line_number_index}"
      )
      retval = false
    end

    unless @else_dest.nil? || program.line_number?(@else_dest)
      console_io.print_line(
        "Line number #{@else_dest} not found in line #{line_number_index}"
      )
      retval = false
    end

    retval
  end

  def renumber(renumber_map)
    unless @destination.nil?
      @destination = renumber_map[@destination]
      index = 0
      i = 0

      @tokens.each do |token|
        index = i if token.to_s == 'THEN'
        i += 1
      end

      @tokens[index + 1] = NumericConstantToken.new(@destination.line_number)
    end

    unless @else_dest.nil?
      @else_dest = renumber_map[@else_dest]
      @tokens[-1] = NumericConstantToken.new(@else_dest.line_number)
    end

    @linenums = make_linenum_references
  end

  def execute_core(interpreter)
    values = @expression.evaluate(interpreter)

    raise(BASICExpressionError, 'Too many or too few values') unless
      values.size == 1

    result = values[0]

    result = BooleanConstant.new(result) unless
      result.class.to_s == 'BooleanConstant'

    if result.value
      unless @destination.nil?
        line_number = @destination
        index = interpreter.statement_start_index(line_number, 0)

        raise(BASICSyntaxError, 'Line number not found') if index.nil?

        destination = LineNumberIndex.new(line_number, 0, index)
        interpreter.next_line_index = destination
      end

      @statement.execute_core(interpreter) unless @statement.nil?
    else
      unless @else_dest.nil?
        line_number = @else_dest
        index = interpreter.statement_start_index(line_number, 0)

        raise(BASICSyntaxError, 'Line number not found') if index.nil?

        destination = LineNumberIndex.new(line_number, 0, index)
        interpreter.next_line_index = destination
      end

      if @else_dest.nil? && @else_stmt.nil? && interpreter.if_false_next_line
        # go to next numbered line, not next statement
        next_line_index = interpreter.find_next_line
        interpreter.next_line_index = next_line_index
      end

      @else_stmt.execute_core(interpreter) unless @else_stmt.nil?
    end

    s = ' ' + @expression.to_s + ': ' + result.to_s
    io = interpreter.trace_out
    io.trace_output(s)
  end

  private

  def parse_target(tokens)
    destination = nil
    statement = nil

    if tokens.class.to_s == 'Hash'
      statement = IfStatement.new(nil, tokens)
    elsif tokens.size == 1 && tokens[0].numeric_constant?
      destination = LineNumber.new(tokens[0])
    else
      statement_factory = StatementFactory.instance
      statement = statement_factory.create_statement(tokens.flatten)
      @errors += statement.errors
    end

    [destination, statement]
  end
end

# IF/THEN
class IfStatement < AbstractIfStatement
  def self.lead_keywords
    [
      [KeywordToken.new('IF')]
    ]
  end

  def self.extra_keywords
    %w[THEN ELSE]
  end

  def initialize(_, _)
    super
  end

  private

  def parse_expression(tokens)
    expression = nil

    begin
      expression = ValueExpression.new(tokens, :scalar)
    rescue BASICExpressionError => e
      @errors << e.message
    end

    expression
  end
end

# INPUT
class InputStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('INPUT')],
      [KeywordToken.new('INP')]
    ]
  end

  include FileFunctions
  include InputFunctions

  def initialize(_, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions(items, :scalar)
      @file_tokens = extract_file_handle(@items)
      @prompt = extract_prompt(@items)
      @elements = make_references(@items, @file_tokens, @prompt)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :read)

    prompt = nil

    unless @prompt.nil?
      prompts = @prompt.evaluate(interpreter)
      prompt = prompts[0]
    end

    # create list of variables with subscripts
    item_names = []

    @items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        item_names << target
      end
    end

    # get all of the needed values
    if fh.nil?
      # from console
      values = input_values(fhr, interpreter, prompt, item_names.size)
      fhr.implied_newline
    else
      # from file
      values = fhr.input(interpreter)
    end

    raise BASICRuntimeError.new('Not enough values', 112) if
      values.size < item_names.size

    name_value_pairs =
      zip(item_names, values[0..item_names.length])

    name_value_pairs.each do |hash|
      variable = hash['name']
      value = hash['value']
      interpreter.set_value(variable, value)
    end

    interpreter.clear_previous_lines
  end
end

# INPUT$
class InputCharStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('INPUT$')]
    ]
  end

  include FileFunctions
  include InputFunctions

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions(items, :scalar)
      @file_tokens = extract_file_handle(@items)
      @prompt = extract_prompt(@items)
      @elements = make_references(@items, @file_tokens, @prompt)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += 1
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :read)

    prompt = nil

    unless @prompt.nil?
      prompts = @prompt.evaluate(interpreter)
      prompt = prompts[0]
    end

    if fh.nil?
      values = input_values(fhr, interpreter, prompt, @items.size)
      fhr.implied_newline
    else
      values = fhr.input(interpreter)
    end

    name_value_pairs =
      zip(@items, values[0..@items.length])

    name_value_pairs.each do |hash|
      variables = hash['name'].evaluate(interpreter)
      variable = variables[0]
      value = NumericConstant.new(hash['value'].ord)
      interpreter.set_value(variable, value)
    end

    interpreter.clear_previous_lines
  end

  private

  def input_values(fhr, _, _, count)
    values = []
    values << fhr.read_char while values.size < count

    values
  end
end

# common functions for LET and LET-less statements
class AbstractLetStatement < AbstractStatement
  def initialize(_, _)
    super
  end

  def dump
    lines = []

    lines += @assignment.dump unless @assignment.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end
end

# common functions for scalar LET and LET-less statement
class AbstractScalarLetStatement < AbstractLetStatement
  def initialize(_, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[3, '>=']]

    if check_template(tokens_lists, template)
      begin
        @assignment = Assignment.new(tokens_lists[0], :scalar)

        if @assignment.count_target.zero?
          @errors << 'Assignment must have left-hand value(s)'
        end

        if @assignment.count_value != 1
          @errors << 'Assignment must have only one right-hand value'
        end

        @elements = make_references(nil, @assignment)
        @comprehension_effort += @assignment.comprehension_effort
      rescue BASICExpressionError => e
        @errors << e.message
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    l_values = @assignment.eval_target(interpreter)
    r_values = @assignment.eval_value(interpreter)
    r_value = r_values[0]

    # allow multiple left-hand side values
    # but only one right-hand side value
    l_values.each do |l_value|
      interpreter.set_value(l_value, r_value)
    end
  end
end

# LET
class LetStatement < AbstractScalarLetStatement
  def self.lead_keywords
    [
      [KeywordToken.new('LET')]
    ]
  end

  def initialize(_, _)
    super
  end
end

# LET-less assignment
class LetLessStatement < AbstractScalarLetStatement
  def self.lead_keywords
    [
      []
    ]
  end

  def initialize(_, _)
    super
  end
end

# LINE INPUT
class LineInputStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('LINE'), KeywordToken.new('INPUT')],
      [KeywordToken.new('INPUT'), KeywordToken.new('LINE')],
      [KeywordToken.new('LINPUT')],
      [KeywordToken.new('LIN')]
    ]
  end

  include FileFunctions
  include InputFunctions

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions(items, :scalar)
      @file_tokens = extract_file_handle(@items)
      @prompt = extract_prompt(@items)
      @elements = make_references(@items, @file_tokens, @prompt)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :read)

    prompt = nil

    unless @prompt.nil?
      prompts = @prompt.evaluate(interpreter)
      prompt = prompts[0]
    end

    if fh.nil?
      values = input_values(fhr, interpreter, prompt, @items.size)
      fhr.implied_newline
    else
      values = fhr.line_input(interpreter)
    end

    name_value_pairs =
      zip(@items, values[0..@items.length])

    name_value_pairs.each do |hash|
      variables = hash['name'].evaluate(interpreter)
      variable = variables[0]
      value = hash['value']
      interpreter.set_value(variable, value)
    end

    interpreter.clear_previous_lines
  end

  private

  def input_values(fhr, interpreter, prompt, count)
    values = []

    while values.size < count
      remaining = count - values.size
      fhr.prompt(prompt, remaining)
      values += fhr.line_input(interpreter)

      prompt = nil
    end

    values
  end
end

# NEXT
class NextStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('NEXT')],
      [KeywordToken.new('NEX')]
    ]
  end

  attr_reader :control

  def initialize(keywords, tokens_lists)
    super

    template = [[1]]

    if check_template(tokens_lists, template)
      # parse control variable
      @control = nil
      if tokens_lists[0][0].variable?
        variable_name = VariableName.new(tokens_lists[0][0])
        @control = Variable.new(variable_name, :scalar, [])
        controlx = XrefEntry.new(@control.to_s, nil, false)
        @elements[:variables] = [controlx]
      else
        @errors << "Invalid control variable #{tokens_lists[0][0]}"
      end
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = [@control.dump]

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    fornext_control = interpreter.retrieve_fornext(@control)

    if interpreter.match_fornext?
      # check control variable matches current loop
      expected = interpreter.top_fornext
      actual = fornext_control.control

      if actual != expected
        raise(BASICSyntaxError,
              "Found NEXT #{actual} when expecting #{expected}")
      end
    end

    # check control variable value
    # if matches end value, stop here
    terminated = fornext_control.terminated?(interpreter)
    io = interpreter.trace_out
    s = ' terminated:' + terminated.to_s
    io.trace_output(s)

    if terminated
      fornext_control.bump_control(interpreter) if
        interpreter.fornext_one_beyond

      interpreter.unlock_variable(@control)
      interpreter.exit_fornext
    else
      # set next line from top item
      interpreter.next_line_index = fornext_control.loop_start_index
      # change control variable value
      fornext_control.bump_control(interpreter)
    end
  end
end

# ON ERROR GOTO
class OnErrorStatement < AbstractStatement
  def self.lead_keywords
    [
      [
        KeywordToken.new('ON'),
        KeywordToken.new('ERROR'),
        KeywordToken.new('GOTO')
      ]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    @destination = nil

    template = [[1]]

    if check_template(tokens_lists, template)
      destinations = tokens_lists[0]
      line_nums = split_tokens(destinations, false)
      destinations = line_nums[0]
      destination = destinations[0]

      if destination.numeric_constant?
        if destination.to_i == 0
          @destination = nil
          @linenums = []
        else
          @destination = LineNumber.new(destination)
          @linenums = [@destination]
        end
      else
        @errors << "Invalid line number #{destination}"
      end

      @mccabe += 1
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    lines << @destination.dump unless @destination.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def gotos
    destinations = []

    destinations << @destination unless @destination.nil?

    destinations
  end

  def program_check(program, console_io, line_number_index)
    retval = true

    unless @destination.nil?
      unless program.line_number?(@destination)
        console_io.print_line(
          "Line number #{@destination} not found in line #{line_number_index}"
        )
        retval = false
      end
    end

    retval
  end

  def execute_core(interpreter)
    interpreter.seterrorgoto(@destination)
  end

  def renumber(renumber_map)
    unless @destination.nil?
      @destination = renumber_map[@destination]
      @linenums = [@destination]
      @tokens[-1] = NumericConstantToken.new(@destination.line_number)
    end
  end
end

# ON GOTO
class OnStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ON')]
    ]
  end

  def self.extra_keywords
    %w[GOTO THEN]
  end

  def initialize(keywords, tokens_lists)
    super

    @destinations = nil
    @expression = nil

    template1 = [[1, '>='], 'GOTO', [1, '>=']]
    template2 = [[1, '>='], 'THEN', [1, '>=']]

    if check_template(tokens_lists, template1) ||
       check_template(tokens_lists, template2)
      expression = tokens_lists[0]

      begin
        @expression = ValueExpression.new(expression, :scalar)
        @elements = make_references(nil, @expression)
      rescue BASICExpressionError => e
        @errors << e.message
      end

      destinations = tokens_lists[2]
      line_nums = split_tokens(destinations, false)
      @destinations = []

      line_nums.each do |line_num|
        if line_num.size == 1
          destination = line_num[0]
          if destination.numeric_constant?
            @destinations << LineNumber.new(destination)
          else
            @errors << "Invalid line number #{destination}"
          end
        else
          @errors << "Invalid line specification #{line_num}"
        end
      end

      @linenums = @destinations
      @comprehension_effort += @expression.comprehension_effort
      @mccabe += @destinations.size
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?

    @destinations.each { |destination| lines << destination.dump } unless
      @destinations.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def gotos
    @destinations
  end

  def program_check(program, console_io, line_number_index)
    retval = true

    unless @destinations.nil?
      @destinations.each do |destination|
        unless program.line_number?(destination)
          console_io.print_line(
            "Line number #{destination} not found in line #{line_number_index}"
          )
          retval = false
        end
      end
    end

    retval
  end

  def execute_core(interpreter)
    values = @expression.evaluate(interpreter)

    raise(BASICExpressionError, 'Expecting one value') unless values.size == 1

    value = values[0]

    raise(BASICExpressionError, 'Invalid value') unless value.numeric_constant?

    io = interpreter.trace_out
    io.trace_output(' ' + @expression.to_s + ' = ' + value.to_s)
    index = value.to_i

    raise BASICRuntimeError.new('Index out of range', 129) if
      index < 1 || index > @destinations.size

    # get destination in list
    line_number = @destinations[index - 1]
    index = interpreter.statement_start_index(line_number, 0)

    raise(BASICSyntaxError, 'Line number not found') if index.nil?

    destination = LineNumberIndex.new(line_number, 0, index)
    interpreter.next_line_index = destination
  end

  def renumber(renumber_map)
    new_destinations = []

    @destinations.each do |destination|
      new_destinations << renumber_map[destination]
    end

    i = 0
    index = 0
    @tokens.each do |token|
      index = i if token.to_s == 'THEN'
      index = i if token.to_s == 'GOTO'
      i += 1
    end

    new_destinations.each do |destination|
      @tokens[index + 1] = NumericConstantToken.new(destination.line_number)

      index += 2
    end

    @destinations = new_destinations
    @linenums = @destinations
  end
end

# OPEN
class OpenStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('OPEN')],
      [KeywordToken.new('OPE')]
    ]
  end

  def self.extra_keywords
    %w[FOR INPUT OUTPUT AS FILE]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template_input_as =
      [[1, '>='], 'FOR', 'INPUT', 'AS', [1, '>=']]

    template_input_as_file =
      [[1, '>='], 'FOR', 'INPUT', 'AS', 'FILE', [1, '>=']]

    template_output_as =
      [[1, '>='], 'FOR', 'OUTPUT', 'AS', [1, '>=']]

    template_output_as_file =
      [[1, '>='], 'FOR', 'OUTPUT', 'AS', 'FILE', [1, '>=']]

    template_update = [[2, '>=']]

    ### TODO: add template OPEN filename FOR MEMORY AS FILE #n

    if check_template(tokens_lists, template_input_as) ||
       check_template(tokens_lists, template_input_as_file)

      @filename_expression = ValueExpression.new(tokens_lists[0], :scalar)
      @filenum_expression = ValueExpression.new(tokens_lists[-1], :scalar)

      @elements =
        make_references(nil, @filename_expression, @filenum_expression)

      @mode = :read
      @comprehension_effort += @filenum_expression.comprehension_effort
      @comprehension_effort += @filename_expression.comprehension_effort
    elsif check_template(tokens_lists, template_output_as) ||
          check_template(tokens_lists, template_output_as_file)

      @filename_expression = ValueExpression.new(tokens_lists[0], :scalar)
      @filenum_expression = ValueExpression.new(tokens_lists[-1], :scalar)

      @elements =
        make_references(nil, @filename_expression, @filenum_expression)

      @mode = :print
      @comprehension_effort += @filenum_expression.comprehension_effort
      @comprehension_effort += @filename_expression.comprehension_effort
    elsif check_template(tokens_lists, template_update)
      split_lists = split_tokens(tokens_lists[0], false)

      @filenum_expression = ValueExpression.new(split_lists[0], :scalar)
      @filename_expression = ValueExpression.new(split_lists[1], :scalar)

      @elements =
        make_references(nil, @filename_expression, @filenum_expression)

      @mode = :memory
      @comprehension_effort += @filenum_expression.comprehension_effort
      @comprehension_effort += @filename_expression.comprehension_effort
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    lines += @filename_expression.dump unless @filename_expression.nil?

    lines += @filenum_expression.dump unless @filenum_expression.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    filenames = @filename_expression.evaluate(interpreter)
    filename = filenames[0]
    fhs = @filenum_expression.evaluate(interpreter)
    fh = FileHandle.new(fhs[0])
    interpreter.open_file(filename, fh, @mode)
  end
end

# OPTION
class OptionStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('OPTION')]
    ]
  end

  def self.extra_keywords
    %w[
      ASC_ALLOW_ALL
      BACK_TAB BASE
      CHR_ALLOW_ALL CRLF_ON_LINE_INPUT
      DEFAULT_PROMPT DETECT_INFINITE_LOOP
      ECHO FIELD_SEP FORNEXT_ONE_BEYOND
      IF_FALSE_NEXT_LINE IGNORE_RND_ARG IMPLIED_SEMICOLON INPUT_HIGH_BIT
      INT_FLOOR LOCK_FORNEXT MATCH_FORNEXT NEWLINE_SPEED
      PRECISION PRINT_SPEED PRINT_WIDTH PROMPT_COUNT PROVENANCE
      QMARK_AFTER_PROMPT REQUIRE_INITIALIZED SEMICOLON_ZONE_WIDTH
      TRACE ZONE_WIDTH
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    # omit HEADING and TIMING as they are not used in the interpreter
    # omit PRETTY_MULTILINE too
    template = [OptionStatement.extra_keywords, [1, '>=']]

    if check_template(tokens_lists, template)
      @key = tokens_lists[0].to_s.downcase
      expression_tokens = split_tokens(tokens_lists[1], true)

      @expression = ValueExpression.new(expression_tokens[0], :scalar)
      @elements = make_references(nil, @expression)
      @comprehension_effort += @expression.comprehension_effort
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute(interpreter)
    values = @expression.evaluate(interpreter)
    value0 = values[0]

    interpreter.set_action(@key, value0.to_v)
  end
end

# PRINT
class PrintStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('PRINT')],
      [KeywordToken.new('PRI')],
      [KeywordToken.new('&')]
    ]
  end

  include FileFunctions
  include PrintFunctions

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template1 = []
    template2 = [[1, '>=']]

    if check_template(tokens_lists, template1)
      @items = tokens_to_expressions([], :scalar)
    elsif check_template(tokens_lists, template2)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :scalar)
      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    i = 0

    @items.each do |item|
      if item.printable?
        carriage = CarriageControl.new('')
        carriage = @items[i + 1] if
          i < @items.size &&
          !@items[i + 1].printable?
        item.print(fhr, interpreter)
        carriage.print(fhr, interpreter)
      end

      i += 1
    end
  end
end

# PRINT USING
class PrintUsingStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('PRINT'), KeywordToken.new('USING')]
    ]
  end

  include FileFunctions
  include PrintFunctions

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @file_tokens = nil
      @items = tokens_to_expressions(tokens_lists, :scalar)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    format_spec, items = extract_format(@items, interpreter)

    raise BASICRuntimeError.new('No print format', 144) if format_spec.nil?

    # split format
    formats = split_format(format_spec)
    fhr = interpreter.console_io

    formats.each do |format|
      constant = nil

      if format.wants_item
        # skip all of the separators
        items.shift while
          !items.empty? && items[0].carriage_control?

        raise BASICRuntimeError.new('Too few print items for format', 145) if
          items.empty?

        item = items.shift
        constants = item.evaluate(interpreter)
        constant = constants[0]
      end

      text = format.format(constant)
      text.print(fhr)
    end

    if !items.empty? && !items[0].printable?
      items.unshift(ValueExpression.new([], :scalar))
    end

    i = 0

    items.each do |item|
      if item.printable?
        carriage = CarriageControl.new('')
        carriage = items[i + 1] if
          i < items.size &&
          !items[i + 1].printable?
        item.print(fhr, interpreter)
        carriage.print(fhr, interpreter)
      end

      i += 1
    end
  end

  private

  def extract_format(items, interpreter)
    items = items.clone
    format = nil

    unless items.empty? ||
           items[0].class.to_s != 'ValueExpression' &&
           items[-1].scalar?

      value = first_item(items, interpreter)

      if value.text_constant?
        format = value
        items.shift

        items.shift if
          !items.empty? &&
          items[0].carriage_control?
      end
    end

    [format, items]
  end

  def first_item(items, interpreter)
    first_list = items[0]
    values = first_list.evaluate(interpreter)

    values[0]
  end

  def split_format(format)
    format_text = format.to_v
    tokenbuilders = [
      ConstantFormatTokenBuilder.new,
      PaddedStringFormatTokenBuilder.new,
      PlainStringFormatTokenBuilder.new,
      CharFormatTokenBuilder.new,
      NumericFormatTokenBuilder.new
    ]
    tokenizer = Tokenizer.new(tokenbuilders, nil)
    tokenizer.tokenize(format_text)
  end
end

# PUT
class PutStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('PUT')]
    ]
  end

  include FileFunctions

  def initialize(keywords, tokens_lists)
    super

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      if items.size == 3
        line_no = items[1]
        if line_no.empty?
          @errors << 'No line number'
        else
          line_num = line_no[0]
          begin
            @line_number = LineNumber.new(line_num)
          rescue BASICSyntaxError => e
            @errors << e.message
          end
        end
      else
        @errors << 'Syntax error'
      end

      @items = tokens_to_expressions(items, :scalar)

      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []
    @items.each { |item| lines += item.dump }
    lines
  end

  def program_check(program, console_io, line_number_index)
    retval = true

    unless program.line_number?(@line_number)
      console_io.print_line(
        "Line number #{@line_number} not found in line #{line_number_index}"
      )
      retval = false
    end

    retval
  end

  def execute_core(interpreter)
    file_no = @items[0]
    fh = get_file_handle(interpreter, file_no)
    fhr = interpreter.get_file_handler(fh, :memory)

    rec_no = @items[2]
    rec_num = rec_no.evaluate(interpreter)
    rec_number = rec_num[0].to_i

    write_items = interpreter.get_record_write_variables(@line_number)

    # write variables from record (use ValueExpressions)
    items = []
    write_items.each do |item|
      values = item.evaluate(interpreter)
      items << values[0].to_s
    end

    # format variables to string
    record = items.join(', ')
    fhr.write_record(record, rec_number)
  end

  def renumber(renumber_map)
    @line_number = renumber_map[@line_number]
    @token_index = -1
    i = 0
    num_commas = 1
    @tokens.each do |token|
      @token_index = i if token.numeric_constant? && num_commas == 1

      num_commas += 1 if token.separator?

      i += 1
    end
    @tokens[@token_index] = NumericConstantToken.new(@line_number.line_number)
  end

  private

  def tokens_to_expressions(tokens_lists, shape)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape)
      end
    end

    items
  end

  def add_expression(items, tokens, shape)
    items << ValueExpression.new(tokens, shape)
  rescue BASICExpressionError
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" is not a value or operator'
  end
end

# RANDOMIZE
class RandomizeStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('RANDOMIZE')],
      [KeywordToken.new('RANDOM')],
      [KeywordToken.new('RAN')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    interpreter.new_random
  end
end

# READ
class ReadStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('READ')],
      [KeywordToken.new('REA')]
    ]
  end

  include FileFunctions
  include ReadFunctions

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions(items, :scalar)
      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    ds = interpreter.get_data_store(fh)

    @items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        value = ds.read
        interpreter.set_value(target, value)
      end
    end

    interpreter.clear_previous_lines
  end
end

# RECORD
class RecordStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('RECORD')],
      [KeywordToken.new('REC')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @read_items, @write_items = tokens_to_expressions(items, :scalar)
      @elements = make_references(@read_items)
      # TODO: merge these two dictionaries
      @elements = make_references(@write_items)
      @mccabe += @write_items.size
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []
    @read_items.each { |item| lines += item.dump }
    @write_items.each { |item| lines += item.dump }
    lines
  end

  def execute_core(interpreter)
    interpreter.set_record_read_variables(@read_items)
    interpreter.set_record_write_variables(@write_items)
  end

  private

  def tokens_to_expressions(tokens_lists, shape)
    read_items = []
    write_items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_target_expression(read_items, tokens_list, shape)
        add_value_expression(write_items, tokens_list, shape)
      end
    end

    [read_items, write_items]
  end

  def add_value_expression(items, tokens, shape)
    items << ValueExpression.new(tokens, shape)
  rescue BASICExpressionError
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" is not a value or operator'
  end

  def add_target_expression(items, tokens, shape)
    items << TargetExpression.new(tokens, shape)
  rescue BASICExpressionError
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" is not a value or operator'
  end
end

# RESTORE
class RestoreStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('RESTORE')],
      [KeywordToken.new('RES')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    ds = interpreter.get_data_store(nil)
    ds.reset
  end
end

# RESUME
class ResumeStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('RESUME')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)
    @autonext = false unless @any_if_modifiers

    template_0 = []
    template_1 = [[1, '>=']]

    target = nil
    if check_template(tokens_lists, template_0)
      target = nil
    elsif check_template(tokens_lists, template_1)
      target = tokens_lists[0][0]
    else
      @errors << 'Syntax error'
    end

    @target = nil
    unless target.nil?
      begin
        @target = LineNumber.new(target)
        @linenums = [@target]
      rescue BASICSyntaxError
        @errors << 'Invalid target'
      end
    end
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    interpreter.resume(@target)
  end
end

# RETURN
class ReturnStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('RETURN')],
      [KeywordToken.new('RET')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)
    @autonext = false unless @any_if_modifiers

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    interpreter.next_line_index = interpreter.pop_return
  end
end

# RUN
class RunStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('RUN')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)
    @autonext = false unless @any_if_modifiers

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    interpreter.rerun
  end
end

# SLEEP
class SleepStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('SLEEP')],
      [KeywordToken.new('SLE')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template_0 = []
    template_1 = [[1, '>=']]

    if check_template(tokens_lists, template_0)
      token_list = [NumericConstantToken.new('5')]
      @expression = ValueExpression.new(token_list, :scalar)
      @comprehension_effort += @expression.comprehension_effort
    elsif check_template(tokens_lists, template_1)
      token_lists = split_tokens(tokens_lists[0], false)
      @expression = ValueExpression.new(token_lists[0], :scalar)
      @elements = make_references(nil, @expression)
      @comprehension_effort += @expression.comprehension_effort
    else
      @errors << 'Syntax error'
    end

    @errors << 'Too many values' if token_lists.size > 1
  end

  def dump
    lines = @expression.dump

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    values = @expression.evaluate(interpreter)
    value = values[0]
    sleep(value.to_v)
  end
end

# STOP
class StopStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('STOP')],
      [KeywordToken.new('STO')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)
    @autonext = false unless @any_if_modifiers

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    io = interpreter.console_io
    io.newline_when_needed
    interpreter.stop
  end
end

# UNSAVE
class UnsaveStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('UNSAVE')],
      [KeywordToken.new('UNS')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]
    template_file = ['FILE', [1, '>=']]

    @filenum_expression = []
    if check_template(tokens_lists, template) ||
       check_template(tokens_lists, template_file)
      @filenum_expression = ValueExpression.new(tokens_lists[-1], :scalar)

      @elements = make_references(nil, @filenum_expression)
      @comprehension_effort += @filenum_expression.comprehension_effort
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    @filenum_expression.dump
  end

  def execute_core(interpreter)
    fns = @filenum_expression.evaluate(interpreter)
    fh = FileHandle.new(fns[0])
    # TODO: reset file to zero length
    interpreter.close_file(fh)
  end
end

# WRITE
class WriteStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('WRITE')],
      [KeywordToken.new('WRI')]
    ]
  end

  include FileFunctions
  include WriteFunctions

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :scalar)
      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    i = 0

    @items.each do |item|
      if item.printable?
        carriage = CarriageControl.new('')
        carriage = @items[i + 1] if
          i < @items.size &&
          !@items[i + 1].printable?
        item.write(fhr, interpreter)
        carriage.write(fhr, interpreter)
      end

      i += 1
    end
  end
end

# ARR INPUT
class ArrInputStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('INPUT')]
    ]
  end

  include FileFunctions
  include InputFunctions

  def initialize(keywords, tokens_lists)
    super

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :array)
      @file_tokens = extract_file_handle(@items)
      @prompt = extract_prompt(@items)
      @elements = make_references(@items, @file_tokens, @prompt)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :read)

    prompt = nil

    unless @prompt.nil?
      prompts = @prompt.evaluate(interpreter)
      prompt = prompts[0]
    end

    # compute size based on variable dimensions
    # create list of variables with subscripts
    item_names = []

    @items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        name = target.name

        interpreter.set_dimensions(target, target.dimensions) if
          target.dimensions?
        
        # make sure dimension is one
        dims = interpreter.get_dimensions(name)
        raise(BASICExpressionError, 'Not an array') unless dims.size == 1

        # build names
        base = interpreter.base
        (base..dims[0].to_i).each do |col|
          coord = AbstractElement.make_coord(col)
          variable = Variable.new(name, :array, coord)
          item_names << variable
        end
      end
    end

    # get all of the needed values
    if fh.nil?
      # from console
      values = input_values(fhr, interpreter, prompt, item_names.size)
      fhr.implied_newline
    else
      # from file
      values = file_values(fhr, interpreter)
    end

    raise BASICRuntimeError.new('Not enough values', 112) if
      values.size < item_names.size

    # use names based on variable dimensions
    name_value_pairs =
      zip(item_names, values[0..item_names.length])

    name_value_pairs.each do |hash|
      variable = hash['name']
      value = hash['value']
      interpreter.set_value(variable, value)
    end

    interpreter.clear_previous_lines
  end
end

# ARR PRINT
class ArrPrintStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('PRINT')]
    ]
  end

  include FileFunctions
  include PrintFunctions

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :array)
      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    i = 0

    @items.each do |item|
      if item.printable?
        carriage = CarriageControl.new('')
        carriage = @items[i + 1] if
          i < @items.size &&
          !@items[i + 1].printable?
        item.compound_print(fhr, interpreter)
        carriage.print(fhr, interpreter)
      end

      i += 1
    end
  end
end

# ARR READ
class ArrReadStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('READ')]
    ]
  end

  include FileFunctions
  include ReadFunctions

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions(items, :array)
      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    ds = interpreter.get_data_store(fh)

    @items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        interpreter.set_dimensions(target, target.dimensions) if
          target.dimensions?
        read_values(target.name, interpreter, ds)
      end
    end

    interpreter.clear_previous_lines
  end

  private

  def read_values(name, interpreter, ds)
    dims = interpreter.get_dimensions(name)
    case dims.size
    when 1
      read_array(name, dims, interpreter, ds)
    else
      raise(BASICSyntaxError, 'Dimensions for ARR READ must be 1')
    end
  end

  def read_array(name, dims, interpreter, ds)
    values = {}

    base = interpreter.base
    (base..dims[0].to_i).each do |col|
      coord = AbstractElement.make_coord(col)
      values[coord] = ds.read
    end

    interpreter.set_values(name, values)
  end
end

# ARR WRITE
class ArrWriteStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('WRITE')]
    ]
  end

  include FileFunctions
  include WriteFunctions

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :array)
      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    i = 0

    @items.each do |item|
      if item.printable?
        carriage = CarriageControl.new('')
        carriage = @items[i + 1] if
          i < @items.size &&
          !@items[i + 1].printable?
        item.compound_write(fhr, interpreter)
        carriage.write(fhr, interpreter)
      end

      i += 1
    end
  end
end

# ARR assignment
class ArrLetStatement < AbstractLetStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR')],
      [KeywordToken.new('ARR'), KeywordToken.new('LET')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[3, '>=']]

    if check_template(tokens_lists, template)
      begin
        @assignment = Assignment.new(tokens_lists[0], :array)

        if @assignment.count_target.zero?
          @errors << 'Assignment must have left-hand value(s)'
        end

        if @assignment.count_value != 1
          @errors << 'Assignment must have only one right-hand value'
        end

        @elements = make_references(nil, @assignment)
        @comprehension_effort += @assignment.comprehension_effort
      rescue BASICExpressionError => e
        @errors << e.message
        @assignment = @rest
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    l_values = @assignment.eval_target(interpreter)
    l_value = l_values[0]
    l_dims = interpreter.get_dimensions(l_value.name)

    interpreter.set_default_args('CON1', l_dims)
    interpreter.set_default_args('ZER1', l_dims)

    r_value = first_value(interpreter)

    interpreter.set_default_args('CON1', nil)
    interpreter.set_default_args('ZER1', nil)

    r_dims = r_value.dimensions

    values = r_value.values(interpreter)

    l_values.each do |l_value|
      interpreter.set_dimensions(l_value, r_dims)
      interpreter.set_values(l_value.name, values)
    end
  end

  private

  def first_target(interpreter)
    l_values = @assignment.eval_target(interpreter)
    l_values[0]
  end

  def first_value(interpreter)
    r_values = @assignment.eval_value(interpreter)
    r_value = r_values[0]

    raise(BASICSyntaxError, 'Expected Array') if
      r_value.class.to_s != 'BASICArray'

    r_value
  end
end

# MAT INPUT
class MatInputStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('INPUT')]
    ]
  end

  include FileFunctions
  include InputFunctions

  def initialize(keywords, tokens_lists)
    super

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :array)
      @file_tokens = extract_file_handle(@items)
      @prompt = extract_prompt(@items)
      @elements = make_references(@items, @file_tokens, @prompt)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :read)

    prompt = nil

    unless @prompt.nil?
      prompts = @prompt.evaluate(interpreter)
      prompt = prompts[0]
    end

    # compute size based on variable dimensions
    # create list of variables with subscripts
    item_names = []

    @items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        name = target.name

        interpreter.set_dimensions(target, target.dimensions) if
          target.dimensions?

        # make sure dimension is one or two
        dims = interpreter.get_dimensions(name)
        raise(BASICExpressionError, 'Not an array') unless
          dims.size == 1 || dims.size == 2

        # build names
        if dims.size == 1
          base = interpreter.base
          (base..dims[0].to_i).each do |col|
            coord = AbstractElement.make_coord(col)
            variable = Variable.new(name, :matrix, coord)
            item_names << variable
          end
        end

        if dims.size == 2
          base = interpreter.base
          (base..dims[0].to_i).each do |row|
            (base..dims[1].to_i).each do |col|
              coords = AbstractElement.make_coords(row, col)
              variable = Variable.new(name, :matrix, coords)
              item_names << variable
            end
          end
        end
      end
    end

    # get all of the needed values
    if fh.nil?
      # from console
      values = input_values(fhr, interpreter, prompt, item_names.size)
      fhr.implied_newline
    else
      # from file
      values = file_values(fhr, interpreter)
    end

    raise BASICRuntimeError.new('Not enough values', 112) if
      values.size < item_names.size

    # use names based on variable dimensions
    name_value_pairs =
      zip(item_names, values[0..item_names.length])

    name_value_pairs.each do |hash|
      variable = hash['name']
      value = hash['value']
      interpreter.set_value(variable, value)
    end

    interpreter.clear_previous_lines
  end
end

# MAT PRINT
class MatPrintStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('PRINT')]
    ]
  end

  include FileFunctions
  include PrintFunctions

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :matrix)
      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    i = 0

    @items.each do |item|
      if item.printable?
        item.compound_print(fhr, interpreter)
        carriage = CarriageControl.new('')
        carriage.print(fhr, interpreter)
      end

      i += 1
    end
  end
end

# MAT READ
class MatReadStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('READ')]
    ]
  end

  include FileFunctions
  include ReadFunctions

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions(items, :matrix)
      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    ds = interpreter.get_data_store(fh)

    @items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        interpreter.set_dimensions(target, target.dimensions) if
          target.dimensions?
        read_values(target.name, interpreter, ds)
      end
    end

    interpreter.clear_previous_lines
  end

  private

  def read_values(name, interpreter, ds)
    dims = interpreter.get_dimensions(name)

    case dims.size
    when 1
      read_vector(name, dims, interpreter, ds)
    when 2
      read_matrix(name, dims, interpreter, ds)
    else
      raise(BASICSyntaxError, 'Dimensions for MAT READ must be 1 or 2')
    end
  end

  def read_vector(name, dims, interpreter, ds)
    values = {}

    base = $options['base'].value

    (base..dims[0].to_i).each do |col|
      coord = AbstractElement.make_coord(col)
      values[coord] = ds.read
    end

    interpreter.set_values(name, values)
  end

  def read_matrix(name, dims, interpreter, ds)
    values = {}

    base = $options['base'].value

    (base..dims[0].to_i).each do |row|
      (base..dims[1].to_i).each do |col|
        coords = AbstractElement.make_coords(row, col)
        values[coords] = ds.read
      end
    end

    interpreter.set_values(name, values)
  end
end

# MAT WRITE
class MatWriteStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('WRITE')]
    ]
  end

  include FileFunctions
  include WriteFunctions

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :matrix)
      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    i = 0

    @items.each do |item|
      if item.printable?
        carriage = CarriageControl.new('')
        carriage = @items[i + 1] if
          i < @items.size &&
          !@items[i + 1].printable?
        item.compound_write(fhr, interpreter)
        carriage.write(fhr, interpreter)
      end

      i += 1
    end
  end
end

# MAT assignment
class MatLetStatement < AbstractLetStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT')],
      [KeywordToken.new('MAT'), KeywordToken.new('LET')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[3, '>=']]

    if check_template(tokens_lists, template)
      begin
        @assignment = Assignment.new(tokens_lists[0], :matrix)

        if @assignment.count_target.zero?
          @errors << 'Assignment must have left-hand value(s)'
        end

        if @assignment.count_value != 1
          @errors << 'Assignment must have only one right-hand value'
        end

        @elements = make_references(nil, @assignment)
        @comprehension_effort += @assignment.comprehension_effort
      rescue BASICRuntimeError => e
        @errors << e.message
        @assignment = @rest
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    l_values = @assignment.eval_target(interpreter)
    l_value = l_values[0]
    l_dims = interpreter.get_dimensions(l_value.name)

    interpreter.set_default_args('CON2', l_dims)
    interpreter.set_default_args('CON', l_dims)
    interpreter.set_default_args('IDN', l_dims)
    interpreter.set_default_args('ZER2', l_dims)
    interpreter.set_default_args('ZER', l_dims)

    # evaluate, use default args if needed
    r_values = @assignment.eval_value(interpreter)
    r_value = r_values[0]

    raise(BASICSyntaxError, 'Expected Matrix') if
      r_value.class.to_s != 'Matrix'

    interpreter.set_default_args('CON2', nil)
    interpreter.set_default_args('CON', nil)
    interpreter.set_default_args('IDN', nil)
    interpreter.set_default_args('ZER2', nil)
    interpreter.set_default_args('ZER', nil)

    r_dims = r_value.dimensions
    values = r_value.values_1 if r_dims.size == 1
    values = r_value.values_2 if r_dims.size == 2

    l_values.each do |l_value|
      interpreter.set_dimensions(l_value, r_dims)
      interpreter.set_values(l_value.name, values)
    end
  end
end
