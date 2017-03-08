# split a line into arguments
class ArgSplitter
  attr_reader :args
  @args = []
  @current_arg = ''
  @parens_level = 0

  def self.split_tokens(tokens, want_separators)
    lists = []
    list = []
    parens_level = 0
    tokens.each do |token|
      if token.operand? && (!list.empty? && list[-1].operand?)
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
      parens_level -= 1 if token.groupend? && parens_level > 0
    end
    lists << list unless list.empty?
    lists
  end

  def self.in_string(c)
    @current_arg += c
    return unless c == '"'
    @args << @current_arg
    @current_arg = ''
  end

  def self.not_in_string(c)
    if [',', ';'].include?(c) && @parens_level.zero?
      separator(c)
    elsif c == '('
      open_parens
    elsif c == ')'
      close_parens
    else
      @current_arg += c
    end
  end

  def self.separator(c)
    @args << @current_arg unless @current_arg.empty?
    @current_arg = ''
    @args << c
  end

  def self.open_parens
    @current_arg += '('
    @parens_level += 1
  end

  def self.close_parens
    @current_arg += ')'
    @parens_level -= 1 unless @parens_level.zero?
  end
end

# Statement factory class
class StatementFactory
  def initialize
    @statement_definitions = statement_definitions
  end

  def parse(text)
    line_number = nil
    m = /\A\d+/.match(text)
    unless m.nil?
      number = NumericConstantToken.new(m[0])
      line_number = LineNumber.new(number)
      line = create(m.post_match)
    end
    [line_number, line]
  end

  private

  def squeeze_out_spaces(text)
    squeezed_text = ''
    in_quotes = false
    text.each_char do |c|
      in_remark = squeezed_text.start_with?('REM')
      in_quotes = !in_quotes if c == '"'
      squeezed_text += c if c != ' ' || in_quotes || in_remark
    end
    squeezed_text
  end

  def create(text)
    squeezed = squeeze_out_spaces(text)
    return Line.new(text, [EmptyStatement.new], []) if squeezed == ''
    return Line.new(text, [RemarkStatement.new('REMARK', text)], []) if
      squeezed[0..5] == 'REMARK'
    return Line.new(text, [RemarkStatement.new('REM', text)], []) if
      squeezed[0..2] == 'REM'

    statements = []
    all_tokens = tokenize(text)
    tokens_lists = split(all_tokens)
    tokens_lists.each do |tokens|
      keyword = extract_keyword(tokens)
      begin
        statement = create_regular_statement(keyword, text, tokens)
      rescue BASICException
        statement = InvalidStatement.new(text)
      end
      statements << statement
    end
    Line.new(text, statements, all_tokens)
  end

  def extract_keyword(tokens)
    keyword = ''
    while !tokens.empty? &&
          (tokens[0].whitespace? || tokens[0].keyword?)
      token = tokens.shift
      keyword << token.to_s if token.keyword?
    end
    keyword
  end

  def split(tokens)
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

  def create_regular_statement(keyword, text, tokens)
    statement = UnknownStatement.new(text)
    statement =
      @statement_definitions[keyword].new(text, tokens) if
        @statement_definitions.key? keyword
    statement
  end

  def tokenize(text)
    tokenizers = make_tokenizers
    invalid_tokenizer = InvalidTokenBuilder.new
    tokenizer = Tokenizer.new(tokenizers, invalid_tokenizer)
    tokenizer.tokenize(text)
  end

  def statement_definitions
    {
      'ARRPRINT' => ArrPrintStatement,
      'ARRREAD' => ArrReadStatement,
      'ARR' => ArrLetStatement,
      'CHANGE' => ChangeStatement,
      'DATA' => DataStatement,
      'DEF' => DefineFunctionStatement,
      'DIM' => DimStatement,
      'END' => EndStatement,
      'FILES' => FilesStatement,
      'FOR' => ForStatement,
      'GOSUB' => GosubStatement,
      'GOTO' => GotoStatement,
      'IF' => IfStatement,
      'INPUT' => InputStatement,
      'LET' => LetStatement,
      '' => LetLessStatement,
      'MATPRINT' => MatPrintStatement,
      'MATREAD' => MatReadStatement,
      'MAT' => MatLetStatement,
      'ON' => OnStatement,
      'NEXT' => NextStatement,
      'PRINT' => PrintStatement,
      'RANDOMIZE' => RandomizeStatement,
      'READ' => ReadStatement,
      'RESTORE' => RestoreStatement,
      'RETURN' => ReturnStatement,
      'STOP' => StopStatement,
      'TRACE' => TraceStatement
    }
  end

  def make_tokenizers
    tokenizers = []

    tokenizers << ListTokenBuilder.new(['\\',':'], StatementSeparatorToken)

    keywords = statement_definitions.keys + %w(THEN TO STEP)
    tokenizers << ListTokenBuilder.new(keywords, KeywordToken)

    operators = [
      '+', '-', '*', '/', '^', '#',
      '<', '<=', '=', '>', '>=', '<>'
    ]
    tokenizers << ListTokenBuilder.new(operators, OperatorToken)

    tokenizers << BreakTokenBuilder.new

    tokenizers << ListTokenBuilder.new(['(', '['], GroupStartToken)
    tokenizers << ListTokenBuilder.new([')', ']'], GroupEndToken)
    tokenizers << ListTokenBuilder.new([',', ';'], ParamSeparatorToken)

    tokenizers <<
      ListTokenBuilder.new(FunctionFactory.function_names, FunctionToken)
    tokenizers << ListTokenBuilder.new(('FNA'..'FNZ').to_a, UserFunctionToken)

    tokenizers << TextTokenBuilder.new
    tokenizers << NumberTokenBuilder.new
    tokenizers << VariableTokenBuilder.new
    tokenizers << ListTokenBuilder.new(%w(TRUE FALSE), BooleanConstantToken)
    tokenizers << WhitespaceTokenBuilder.new
  end
end

# parent of all statement classes
class AbstractStatement
  attr_reader :errors

  def initialize(keyword, text)
    @keyword = keyword
    @text = text
    @errors = []
  end

  def pre_execute(_)
    0
  end

  def pretty
    if @errors.empty?
      ' ' + to_s
    else
      @text
    end
  end

  protected

  def remove_break_tokens(tokens)
    new_list = []

    tokens.each do |token|
      new_list << token unless token.class.to_s == 'BreakToken'
    end

    new_list
  end

  def remove_whitespace_tokens(tokens)
    new_list = []

    tokens.each do |token|
      new_list << token unless token.class.to_s == 'WhitespaceToken'
    end

    new_list
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

  def make_coord(c)
    [NumericConstant.new(c)]
  end

  def make_coords(r, c)
    [NumericConstant.new(r), NumericConstant.new(c)]
  end
end

# unparsed statement
class InvalidStatement < AbstractStatement
  def initialize(line)
    super('', line)
    @errors << "Invalid statement"
  end

  def to_s
    @text
  end

  def execute(interpreter, _)
    raise(BASICException, @errors[0])
  end

  def pre_execute(interpreter)
    raise(BASICException, @errors[0])
  end
end

# unknown statement
class UnknownStatement < AbstractStatement
  def initialize(line)
    super('', line)
    @errors << "Unknown statement '#{@text.strip}'"
  end

  def to_s
    @text
  end

  def execute(_, _)
    0
  end
end

# empty statement (line number only)
class EmptyStatement < AbstractStatement
  def initialize
    super('', '')
  end

  def to_s
    ''
  end

  def execute(_, _)
    0
  end
end

# REMARK
class RemarkStatement < AbstractStatement
  def initialize(keyword, line)
    super(keyword, line)
    # override the method to squeeze spaces from line
    squeezed = line.strip
    index = keyword.size
    @rest = squeezed[index..-1]
  end

  def to_s
    @keyword + @rest
  end

  def execute(_, _)
    0
  end
end

# CHANGE
class ChangeStatement < AbstractStatement
  def initialize(line, tokens)
    super('CHANGE', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    parts = split_on_token(tokens, 'TO')
    raise(BASICException, 'Missing value') if
      parts.empty? || parts[0].to_s == 'TO'
    raise(BASICException, 'Missing \'TO\'') if
      parts.size < 2 || parts[1].to_s != 'TO'
    raise(BASICException, 'Missing target') if parts.size != 3
    raise(BASICException, 'Invalid source') if parts[0].size != 1
    @source = VariableName.new(parts[0][0])
    raise(BASICException, 'Invalid target') if parts[2].size != 1
    @target = VariableName.new(parts[2][0])
  end

  def to_s
    @keyword + ' ' + @source.to_s + ' TO ' + @target.to_s
  end

  def execute(interpreter, trace)
    if @source.content_type == 'TextConstant' &&
       @target.content_type == 'NumericConstant'

      # string to array
      text = interpreter.get_value(@source)
      array = text.unpack
      dims = array.dimensions
      target_variable = Variable.new(@target)
      interpreter.set_dimensions(target_variable, dims)
      values = array.values
      interpreter.set_values(@target, values, trace)

    elsif @source.content_type == 'NumericConstant' &&
          @target.content_type == 'TextConstant'

      # array to string
      dims = interpreter.get_dimensions(@source)
      raise(BASICException, 'Source must have 1 dimension') unless
        dims.size == 1
      cols = dims[0].to_i
      values = {}
      (0..cols).each do |col|
        variable = Variable.new(@source, [col])
        coord = make_coord(col)
        values[coord] = interpreter.get_value(variable)
      end
      array = BASICArray.new(dims, values)
      text = array.pack
      interpreter.set_value(@target, text, trace)

    else
      raise BASICException, 'Type mismatch'
    end
  end
end

# DIM
class DimStatement < AbstractStatement
  def initialize(line, tokens)
    super('DIM', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    tokens_lists = ArgSplitter.split_tokens(tokens, false)

    @errors << 'No variables specified' if tokens_lists.empty?

    @expression_list = []
    tokens_lists.each do |tokens_list|
      begin
        @expression_list <<
          TargetExpression.new(tokens_list, VariableDimension)
      rescue BASICException
        @errors << 'Invalid variable ' + tokens_list.map(&:to_s).join
      end
    end
  end

  def to_s
    @keyword + ' ' + @expression_list.join(', ')
  end

  def execute(interpreter, _)
    @expression_list.each do |expression|
      variables = expression.evaluate(interpreter)
      variable = variables[0]
      subscripts = variable.subscripts
      if subscripts.empty?
        raise BASICException, 'DIM statement requires subscript range'
      end
      interpreter.set_dimensions(variable, subscripts)
    end
  end
end

# FILES
class FilesStatement < AbstractStatement
  def initialize(line, tokens)
    super('FILES', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    @expressions = ValueScalarExpression.new(tokens)
  end

  def to_s
    @keyword + ' ' + @expressions.to_s
  end

  def pre_execute(interpreter)
    file_names = @expressions.evaluate(interpreter)
    interpreter.add_file_names(file_names)
  end

  def execute(_, _)
    0
  end
end

# LET
class LetStatement < AbstractStatement
  def initialize(line, tokens)
    super('LET', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    begin
      @assignment = ScalarAssignment.new(tokens)
      if @assignment.count_target.zero?
        @errors << 'Assignment must have left-hand value(s)'
      end
      if @assignment.count_value != 1
        @errors << 'Assignment must have only one right-hand value'
      end
    rescue BASICException => e
      @errors << e.message
    end
  end

  def to_s
    @keyword + ' ' + @assignment.to_s
  end

  def execute(interpreter, trace)
    l_values = @assignment.eval_target(interpreter)
    r_values = @assignment.eval_value(interpreter)
    r_value = r_values[0]
    l_values.each do |l_value|
      interpreter.set_value(l_value, r_value, trace)
    end
  end
end

# LET-less assignment
class LetLessStatement < AbstractStatement
  def initialize(line, tokens)
    super('', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    begin
      @assignment = ScalarAssignment.new(tokens)
      if @assignment.count_target.zero?
        @errors << 'Assignment must have left-hand value(s)'
      end
      if @assignment.count_value != 1
        @errors << 'Assignment must have only one right-hand value'
      end
    rescue BASICException => e
      @errors << e.message
    end
  end

  def to_s
    @assignment.to_s
  end

  def execute(interpreter, trace)
    l_values = @assignment.eval_target(interpreter)
    r_values = @assignment.eval_value(interpreter)
    r_value = r_values[0]
    l_values.each do |l_value|
      interpreter.set_value(l_value, r_value, trace)
    end
  end
end

# INPUT
class InputStatement < AbstractStatement
  def initialize(line, tokens)
    super('INPUT', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    @tokens_lists = ArgSplitter.split_tokens(tokens, false)
    # [prompt string] variable [variable]...

    @default_prompt = TextConstantToken.new('"? "')
  end

  def to_s
    list = []
    @tokens_lists.each do |tokens_list|
      s = ''
      tokens_list.each { |token| s += token.to_s }
      list << s
    end
    @keyword + ' ' + list.join(', ')
  end

  def execute(interpreter, trace)
    tokens_lists = @tokens_lists.clone
    prompt = @default_prompt
    unless tokens_lists.size.zero?
      begin
        value = first_value(tokens_lists, interpreter)
        fh = nil
        if value.class.to_s == 'FileHandle'
          fh = value
          tokens_lists.shift
          value = first_value(tokens_lists, interpreter)
        end
        token = first_token(tokens_lists)
        if token.text_constant?
          prompt = value
          tokens_lists.shift
        end
      rescue BASICException
      end
    end
    expression_list = []
    tokens_lists.each do |items_list|
      begin
        expression_list << TargetExpression.new(items_list, ScalarReference)
      rescue BASICException
        raise(BASICException, 'Invalid variable ' + items_list.map(&:to_s).join)
      end
    end
    if fh.nil?
      io = interpreter.console_io
      values =
        input_values(interpreter, prompt, @default_prompt, expression_list.size)
      io.implied_newline
    else
      values =
        file_values(interpreter, fh)
    end
    begin
      name_value_pairs =
        zip(expression_list, values[0, expression_list.length])
    rescue BASICException
      raise(BASICException, 'End of file') unless fh.nil?
      raise(BASICException, 'Unequal lists')
    end
    name_value_pairs.each do |hash|
      l_values = hash['name'].evaluate(interpreter)
      l_value = l_values[0]
      value = hash['value']
      interpreter.set_value(l_value, value, trace)
    end
  end

  private

  def first_token(tokens_lists)
    first_list = tokens_lists[0]
    first_list[0]
  end

  def first_value(tokens_lists, interpreter)
    first_list = tokens_lists[0]
    expr = ValueScalarExpression.new(first_list)
    values = expr.evaluate(interpreter)
    values[0]
  end

  def zip(names, values)
    raise(BASICException, 'Unequal lists') if names.size != values.size
    results = []
    (0...names.size).each do |i|
      results << { 'name' => names[i], 'value' => values[i] }
    end
    results
  end

  def input_values(interpreter, prompt, default_prompt, count)
    values = []
    io = interpreter.console_io
    while values.size < count
      io.prompt(prompt)
      values += io.input(interpreter)

      prompt = default_prompt
    end
    values
  end

  def file_values(interpreter, fh)
    values = []
    io = interpreter.get_input(fh)
    values += io.input(interpreter)
    values
  end
end

# IF/THEN
class IfStatement < AbstractStatement
  def initialize(line, tokens)
    super('IF', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    parts = split_keywords(tokens)
    if parts.size == 3
      parse_line(parts[0], parts[1], parts[2][0])
    else
      @errors << 'Syntax error'
    end
  end

  def to_s
    @keyword + ' ' + @expression.to_s + ' THEN ' + @destination.to_s
  end

  def execute(interpreter, trace)
    io = interpreter.console_io
    s = ' ' + @expression.to_s
    io.trace_output(s) if trace
    values = @expression.evaluate(interpreter)
    raise(BASICException, 'Expression error') unless
      values.size == 1
    result = values[0]
    raise(BASICException, 'Expression error') unless
      result.class.to_s == 'BooleanConstant'
    interpreter.next_line_index = @destination if result.value
    return unless trace
    s = ' ' + result.to_s
    io.trace_output(s)
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

  private

  def parse_line(expression, keyword, destination)
    if destination.numeric_constant?
      @destination = LineNumberIndex.new(LineNumber.new(destination), 0)
    else
      @errors << "Invalid line number #{destination}"
    end
    @errors << 'Missing THEN' unless keyword.to_s == 'THEN'
    begin
      @expression = ValueScalarExpression.new(expression)
    rescue BASICException => e
      @errors << e.message
    end
  end
end

# common for PRINT, ARR PRINT, MAT PRINT
class AbstractPrintStatement < AbstractStatement
  def initialize(keyword, line, final_carriage)
    super(keyword, line)
    @final = final_carriage
  end

  def to_s
    s = ''
    @tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        s << ' '
        s << tokens_list.map(&:to_s).join
      else
        s << tokens_list.to_s
      end
    end

    if @tokens_lists.size.zero?
      @keyword
    else
      @keyword + s
    end
  end

  def extract_file_handle(print_items, interpreter)
    print_items = print_items.clone
    file_handle = nil
    unless print_items.size.zero? || print_items[0].class.to_s == 'CarriageControl'
      value = first_item(print_items, interpreter)
      if value.class.to_s == 'FileHandle'
        file_handle = value
        print_items.shift
        print_items.shift if print_items[0].class.to_s == 'CarriageControl'
      end
    end
    [file_handle, print_items]
  end

  def first_item(print_items, interpreter)
    first_list = print_items[0]
    values = first_list.evaluate(interpreter)
    values[0]
  end

  def add_implied_items(print_items)
    print_items << CarriageControl.new('NL') if print_items.empty?
    print_items << @final if print_items[-1].printable?
  end
end

# PRINT
class PrintStatement < AbstractPrintStatement
  def initialize(line, tokens)
    super('PRINT', line, CarriageControl.new('NL'))
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    @tokens_lists = ArgSplitter.split_tokens(tokens, true)
    @print_items = tokens_to_expressions(@tokens_lists)
  end

  def execute(interpreter, _)
    file_handle, print_items = extract_file_handle(@print_items, interpreter)
    fh = interpreter.get_file_handler(file_handle)
    print_items.each do |item|
      item.print(fh, interpreter)
    end
  end

  private

  def tokens_to_expressions(tokens_lists)
    print_items = []
    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'ParamSeparatorToken'
        print_items << CarriageControl.new(tokens_list.to_s)
      elsif tokens_list.class.to_s == 'Array'
        add_expression(print_items, tokens_list)
      end
    end
    add_implied_items(print_items)
    print_items
  end

  def add_expression(print_items, tokens)
    if !print_items.empty? &&
       print_items[-1].class.to_s == 'ValueScalarExpression'
      print_items << CarriageControl.new('')
    end
    begin
      print_items << ValueScalarExpression.new(tokens)
    rescue BASICException
      line_text = tokens.map(&:to_s).join
      @errors << 'Syntax error: "' + line_text + '" is not a value or operator'
    end
  end
end

# GOTO
class GotoStatement < AbstractStatement
  def initialize(line, tokens)
    super('GOTO', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    if tokens.size == 1
      if tokens[0].numeric_constant?
        @destination = LineNumberIndex.new(LineNumber.new(tokens[0]), 0)
      else
        @errors << "Invalid line number #{tokens[0]}"
      end
    else
      @errors << 'Syntax error'
    end
  end

  def to_s
    @keyword + ' ' + @destination.to_s
  end

  def execute(interpreter, _)
    interpreter.next_line_index = @destination
  end
end

# GOSUB
class GosubStatement < AbstractStatement
  def initialize(line, tokens)
    super('GOSUB', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    if tokens.size == 1
      if tokens[0].numeric_constant?
        @destination = LineNumberIndex.new(LineNumber.new(tokens[0]), 0)
      else
        @errors << "Invalid line number #{tokens[0]}"
      end
    else
      @errors << 'Syntax error'
    end
  end

  def to_s
    @keyword + ' ' + @destination.to_s
  end

  def execute(interpreter, _)
    interpreter.push_return(interpreter.next_line_index)
    interpreter.next_line_index = @destination
  end
end

# RETURN
class ReturnStatement < AbstractStatement
  def initialize(line, _tokens)
    super('RETURN', line)
  end

  def to_s
    @keyword
  end

  def execute(interpreter, _)
    interpreter.next_line_index = interpreter.pop_return
  end
end

# ON GOTO
class OnStatement < AbstractStatement
  def initialize(line, tokens)
    super('ON', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    # ON expression GOTO destinations
    parts = split_on_token(tokens, 'GOTO')
    @errors << 'Syntax error' if parts.size != 3
    expression = parts[0]
    keyword = parts[1]
    destinations = parts[2]
    @errors << 'Missing GOTO' unless keyword.to_s == 'GOTO'
    begin
      @expression = ValueScalarExpression.new(expression)
    rescue BASICException => e
      @errors << e.message
    end
    line_nums = ArgSplitter.split_tokens(destinations, false)
    @destinations = []
    line_nums.each do |line_num|
      if line_num.size == 1
        destination = line_num[0]
        if destination.numeric_constant?
          @destinations << LineNumberIndex.new(LineNumber.new(destination), 0)
        else
          @errors << "Invalid line number #{destination}"
        end
      else
        @errors << "Invalid line specification #{line_num}"
      end
    end
  end

  def to_s
    s = @expression.to_s + ' GOTO ' + @destinations.map(&:to_s).join(', ')
    @keyword + ' ' + s
  end

  def execute(interpreter, trace)
    values = @expression.evaluate(interpreter)
    raise(BASICException, 'Expecting one value') unless values.size == 1
    value = values[0]
    raise(BASICException, 'Invalid value') unless
      value.class.to_s == 'NumericConstant'
    puts ' ' + @expression.to_s + ' = ' + value.to_s if trace
    index = value.to_i
    raise(BASICException, 'Index out of range') if
      index < 1 || index > @destinations.size
    # get destination in list
    interpreter.next_line_index = @destinations[index - 1]
  end
end

# Helper class for FOR/NEXT
class ForNextControl
  attr_reader :control
  attr_reader :start_line_index
  attr_reader :end

  def initialize(control, start_line_index,
                 start, endv, step_value)
    @control = control
    @start_line_index = start_line_index
    @start = start
    @end = endv
    @step_value = step_value
    @current_value = start
  end

  def bump_control(interpreter, trace)
    @current_value += @step_value
    interpreter.set_value(@control, @current_value, trace)
  end

  def front_terminated?
    zero = NumericConstant.new(0)
    if @step_value > zero
      @start > @end
    elsif @step_value < zero
      @start < @end
    else
      false
    end
  end

  def terminated?(interpreter)
    zero = NumericConstant.new(0)
    current_value = interpreter.get_value(@control)
    if @step_value > zero
      current_value + @step_value > @end
    elsif @step_value < zero
      current_value + @step_value < @end
    else
      false
    end
  end
end

# FOR statement
class ForStatement < AbstractStatement
  def initialize(line, tokens)
    super('FOR', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    # parse control variable, '=', numeric_expression, "TO",
    # numeric_expression, "STEP", numeric_expression
    begin
      tokens2 = make_control(tokens)
      tokens3 = make_to_value(tokens2)
      make_step_value(tokens3)
    rescue BASICException => e
      @errors << e.message
    end
  end

  def to_s
    if @has_step_value
      "#{@keyword} #{@control} = #{@start} TO #{@end}" + " STEP #{@step_value}"
    else
      "#{@keyword} #{@control} = #{@start} TO #{@end}"
    end
  end

  def execute(interpreter, trace)
    from = @start.evaluate(interpreter)[0]
    to = @end.evaluate(interpreter)[0]
    step = @step_value.evaluate(interpreter)[0]

    interpreter.set_value(@control, from, false)
    fornext_control =
      ForNextControl.new(@control, interpreter.next_line_index, from, to, step)

    interpreter.assign_fornext(fornext_control)
    terminated = fornext_control.front_terminated?
    interpreter.next_line_index =
      interpreter.find_closing_next(@control) if terminated

    io = interpreter.console_io
    print_trace_info(io, from, to, step, terminated) if
      trace
  end

  private

  def make_control(tokens)
    parts = split_on_token(tokens, '=')
    raise(BASICException, 'Incorrect initialization') if parts.size != 3
    raise(BASICException, 'Incorrect initialization') if parts[1].to_s != '='
    if parts[0][0].variable?
      @control = VariableName.new(parts[0][0])
    else
      @errors << 'Control variable must be a variable'
    end
    parts[2]
  end

  def make_to_value(tokens)
    parts = split_on_token(tokens, 'TO')
    raise(BASICException, 'Missing start value') if
      parts.empty? || parts[0].to_s == 'TO'
    raise(BASICException, 'Missing \'TO\'') if
      parts.size < 2 || parts[1].to_s != 'TO'
    raise(BASICException, 'Missing end value') if parts.size != 3
    @start = ValueScalarExpression.new(parts[0])
    parts[2]
  end

  def make_step_value(tokens)
    parts = split_on_token(tokens, 'STEP')
    tokens_e = parts[0]
    @end = ValueScalarExpression.new(tokens_e)

    @has_step_value = parts.size == 3
    if @has_step_value
      tokens_s = parts[2]
      @step_value = ValueScalarExpression.new(tokens_s)
    else
      @step_value = ValueScalarExpression.new([NumericConstantToken.new(1)])
    end
  end

  def print_trace_info(io, from, to, step, terminated)
    io.trace_output(" #{@start} = #{from}")
    io.trace_output(" #{@end} = #{to}")
    io.trace_output(" #{@step_value} = #{step}")
    io.trace_output(" terminated:#{terminated}")
  end
end

# NEXT
class NextStatement < AbstractStatement
  attr_reader :control

  def initialize(line, tokens)
    super('NEXT', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    # parse control variable
    @control = nil
    if tokens.size == 1
      if tokens[0].variable?
        @control = VariableName.new(tokens[0])
      else
        @errors << "Invalid control variable #{tokens[0]}"
      end
    else
      @errors << 'Syntax error'
    end
  end

  def to_s
    @keyword + ' ' + @control.to_s
  end

  def execute(interpreter, trace)
    fornext_control = interpreter.retrieve_fornext(@control)
    # check control variable value
    # if matches end value, stop here
    terminated = fornext_control.terminated?(interpreter)
    if trace
      io = interpreter.console_io
      s = ' terminated:' + terminated.to_s
      io.trace_output(s)
    end
    return if terminated
    # set next line from top item
    interpreter.next_line_index = fornext_control.start_line_index
    # change control variable value
    fornext_control.bump_control(interpreter, trace)
  end
end

# common for READ, ARR READ, MAT READ
class AbstractReadStatement < AbstractStatement
  def initialize(line, tokens)
    super
  end

  def to_s
    list = []
    @tokens_lists.each do |tokens_list|
      s = ''
      tokens_list.each { |token| s += token.to_s }
      list << s
    end
    @keyword + ' ' + list.join(', ')
  end

  private

  def extract_file_handle(tokens_lists, interpreter)
    tokens_lists = tokens_lists.clone
    file_handle = nil
    begin
      unless tokens_lists.size.zero? || tokens_lists[0].class.to_s == 'CarriageControl'
        value = first_value(tokens_lists, interpreter)
        if value.class.to_s == 'FileHandle'
          file_handle = value
          tokens_lists.shift
          tokens_lists.shift if tokens_lists[0].class.to_s == 'CarriageControl'
        end
      end
    rescue BASICException
    end
    [file_handle, tokens_lists]
  end

  def first_value(tokens_lists, interpreter)
    first_list = tokens_lists[0]
    expr = ValueScalarExpression.new(first_list)
    values = expr.evaluate(interpreter)
    values[0]
  end
end

# READ
class ReadStatement < AbstractReadStatement
  def initialize(line, tokens)
    super('READ', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    @tokens_lists = ArgSplitter.split_tokens(tokens, false)
  end

  def execute(interpreter, trace)
    tokens_lists = @tokens_lists
    unless tokens_lists.size.zero?
      fh, tokens_lists = extract_file_handle(tokens_lists, interpreter)
    end
    expression_list = []
    tokens_lists.each do |tokens_list|
      begin
        expression_list << TargetExpression.new(tokens_list, ScalarReference)
      rescue BASICException
        raise(BASICException, 'Invalid variable ' + tokens_list.map(&:to_s).join)
      end
    end

    ds = interpreter.get_data_store(fh)
    expression_list.each do |expression|
      targets = expression.evaluate(interpreter)
      targets.each do |target|
        value = ds.read
        interpreter.set_value(target, value, trace)
      end
    end
  end
end

# DATA
class DataStatement < AbstractStatement
  def initialize(line, tokens)
    super('DATA', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    @expressions = ValueScalarExpression.new(tokens)
  end

  def to_s
    @keyword + ' ' + @expressions.to_s
  end

  def pre_execute(interpreter)
    ds = interpreter.get_data_store(nil)
    data_list = @expressions.evaluate(interpreter)
    ds.store(data_list)
  end

  def execute(_, _)
    0
  end
end

# RESTORE
class RestoreStatement < AbstractStatement
  def initialize(line, _tokens)
    super('RESTORE', line)
  end

  def to_s
    @keyword
  end

  def execute(interpreter, _)
    ds = interpreter.get_data_store(nil)
    ds.reset
  end
end

# DEF FNx
class DefineFunctionStatement < AbstractStatement
  def initialize(line, tokens)
    super('DEF', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    @name = ''
    @arguments = []
    @template = ''
    begin
      user_function_definition = UserFunctionDefinition.new(tokens)
      @name = user_function_definition.name
      @arguments = user_function_definition.arguments
      @template = user_function_definition.template
    rescue BASICException => e
      puts e.message
      @errors << e.message
    end
  end

  def to_s
    @keyword + ' ' + @name + "(#{@arguments.join(',')}) = " + @template.to_s
  end

  def pre_execute(interpreter)
    interpreter.set_user_function(@name, @arguments, @template)
  end

  def execute(_, _) end
end

# STOP
class StopStatement < AbstractStatement
  def initialize(line, _tokens)
    super('STOP', line)
  end

  def to_s
    @keyword
  end

  def execute(interpreter, _)
    io = interpreter.console_io
    io.newline_when_needed
    interpreter.stop
  end
end

# END
class EndStatement < AbstractStatement
  def initialize(line, _tokens)
    super('END', line)
  end

  def to_s
    @keyword
  end

  def execute(interpreter, _)
    io = interpreter.console_io
    io.newline_when_needed
    interpreter.stop
  end
end

# TRACE
class TraceStatement < AbstractStatement
  def initialize(line, tokens)
    super('TRACE', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    @tokens_lists = ArgSplitter.split_tokens(tokens, false)
    @errors << 'TRACE needs one value' if @tokens_lists.size != 1
  end

  def execute(interpreter, _)
    first_expression = @tokens_lists[0]
    expression = ValueScalarExpression.new(first_expression)
    value = expression.evaluate(interpreter)
    interpreter.trace(value)
  end

  def to_s
    s = ''
    @tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        s << ' '
        s << tokens_list.map(&:to_s).join
      else
        s << tokens_list.to_s
      end
    end

    if @tokens_lists.size.zero?
      @keyword
    else
      @keyword + s
    end
  end
end

# ARR PRINT
class ArrPrintStatement < AbstractPrintStatement
  def initialize(line, tokens)
    super('ARR PRINT', line, CarriageControl.new(','))
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    @tokens_lists = ArgSplitter.split_tokens(tokens, true)
    @print_items = tokens_to_expressions(@tokens_lists)
  end

  def execute(interpreter, _)
    file_handle, print_items = extract_file_handle(@print_items, interpreter)
    fh = interpreter.get_file_handler(file_handle)
    i = 0
    print_items.each do |item|
      if item.printable?
        carriage = CarriageControl.new('')
        carriage = print_items[i + 1] if
          i < print_items.size &&
          !print_items[i + 1].printable?
        item.print(fh, interpreter, carriage)
      end
      i += 1
    end
  end

  private

  def tokens_to_expressions(tokens_lists)
    print_items = []
    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'ParamSeparatorToken'
        print_items << CarriageControl.new(tokens_list)
      elsif tokens_list.class.to_s == 'Array'
        print_items << ValueArrayExpression.new(tokens_list)
      end
    end
    add_implied_items(print_items)
    print_items
  end
end

# ARR READ
class ArrReadStatement < AbstractReadStatement
  def initialize(line, tokens)
    super('ARR READ', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    @tokens_lists = ArgSplitter.split_tokens(tokens, false)
  end

  def execute(interpreter, trace)
    tokens_lists = @tokens_lists
    unless tokens_lists.size.zero?
      fh, tokens_lists = extract_file_handle(tokens_lists, interpreter)
    end
    expression_list = []
    tokens_lists.each do |tokens_list|
      begin
        expression = TargetExpression.new(tokens_list, ArrayReference)
        expression_list << expression
      rescue BASICException
        raise(BASICException, 'Invalid variable ' + tokens_list.map(&:to_s).join)
      end
    end

    ds = interpreter.get_data_store(fh)
    expression_list.each do |expression|
      targets = expression.evaluate(interpreter)
      targets.each do |target|
        interpreter.set_dimensions(target, target.dimensions) if
          target.dimensions?
        read_values(target.name, interpreter, ds, trace)
      end
    end
  end

  private

  def read_values(name, interpreter, ds, trace)
    dims = interpreter.get_dimensions(name)
    case dims.size
    when 1
      read_array(name, dims, interpreter, ds, trace)
    else
      raise(BASICException, 'Dimensions for ARR READ must be 1')
    end
  end

  def read_array(name, dims, interpreter, ds, trace)
    values = {}
    (0..dims[0].to_i).each do |col|
      coord = make_coord(col)
      values[coord] = ds.read
    end
    interpreter.set_values(name, values, trace)
  end
end

# ARR assignment
class ArrLetStatement < AbstractStatement
  def initialize(line, tokens)
    super('ARR', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    begin
      @assignment = ArrayAssignment.new(tokens) ###
      if @assignment.count_target.zero?
        @errors << 'Assignment must have left-hand value(s)'
      end
      if @assignment.count_value != 1
        @errors << 'Assignment must have only one right-hand value'
      end
    rescue BASICException => e
      @errors << e.message
      @assignment = @rest
    end
  end

  def to_s
    @keyword + ' ' + @assignment.to_s
  end

  def execute(interpreter, trace)
    r_value = first_value(interpreter)
    dims = r_value.dimensions
    values = r_value.values

    l_values = @assignment.eval_target(interpreter)
    l_values.each do |l_value|
      interpreter.set_dimensions(l_value, dims)
      interpreter.set_values(l_value.name, values, trace)
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
    raise(BASICException, 'Expected Array') if
      r_value.class.to_s != 'BASICArray'
    r_value
  end
end

# MAT PRINT
class MatPrintStatement < AbstractPrintStatement
  def initialize(line, tokens)
    super('MAT PRINT', line, CarriageControl.new(','))
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    @tokens_lists = ArgSplitter.split_tokens(tokens, true)
    @print_items = tokens_to_expressions(@tokens_lists)
  end

  def execute(interpreter, _)
    file_handle, print_items = extract_file_handle(@print_items, interpreter)
    fh = interpreter.get_file_handler(file_handle)
    i = 0
    print_items.each do |item|
      if item.printable?
        carriage = CarriageControl.new('')
        carriage = print_items[i + 1] if
          i < print_items.size &&
          !print_items[i + 1].printable?
        item.print(fh, interpreter, carriage)
      end
      i += 1
    end
  end

  private

  def tokens_to_expressions(tokens_lists)
    print_items = []
    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'ParamSeparatorToken'
        print_items << CarriageControl.new(tokens_list)
      elsif tokens_list.class.to_s == 'Array'
        print_items << ValueMatrixExpression.new(tokens_list)
      end
    end
    add_implied_items(print_items)
    print_items
  end
end

# MAT READ
class MatReadStatement < AbstractReadStatement
  def initialize(line, tokens)
    super('MAT READ', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    @tokens_lists = ArgSplitter.split_tokens(tokens, false)
  end

  def execute(interpreter, trace)
    tokens_lists = @tokens_lists
    unless tokens_lists.size.zero?
      fh, tokens_lists = extract_file_handle(tokens_lists, interpreter)
    end
    expression_list = []
    tokens_lists.each do |tokens_list|
      begin
        expression = TargetExpression.new(tokens_list, MatrixReference)
        expression_list << expression
      rescue BASICException
        raise(BASICException, 'Invalid variable ' + tokens_list.map(&:to_s).join)
      end
    end

    ds = interpreter.get_data_store(fh)
    expression_list.each do |expression|
      targets = expression.evaluate(interpreter)
      targets.each do |target|
        interpreter.set_dimensions(target, target.dimensions) if
          target.dimensions?
        read_values(target.name, interpreter, ds, trace)
      end
    end
  end

  private

  def read_values(name, interpreter, ds, trace)
    dims = interpreter.get_dimensions(name)
    case dims.size
    when 1
      read_vector(name, dims, interpreter, ds, trace)
    when 2
      read_matrix(name, dims, interpreter, ds, trace)
    else
      raise(BASICException, 'Dimensions for MAT READ must be 1 or 2')
    end
  end

  def read_vector(name, dims, interpreter, ds, trace)
    values = {}
    (1..dims[0].to_i).each do |col|
      coord = make_coord(col)
      values[coord] = ds.read
    end
    interpreter.set_values(name, values, trace)
  end

  def read_matrix(name, dims, interpreter, ds, trace)
    values = {}
    (1..dims[0].to_i).each do |row|
      (1..dims[1].to_i).each do |col|
        coords = make_coords(row, col)
        values[coords] = ds.read
      end
    end
    interpreter.set_values(name, values, trace)
  end
end

# MAT assignment
class MatLetStatement < AbstractStatement
  def initialize(line, tokens)
    super('MAT', line)
    tokens = remove_break_tokens(tokens)
    tokens = remove_whitespace_tokens(tokens)
    begin
      @assignment = MatrixAssignment.new(tokens)
      if @assignment.count_target.zero?
        @errors << 'Assignment must have left-hand value(s)'
      end
      if @assignment.count_value != 1
        @errors << 'Assignment must have only one right-hand value'
      end
    rescue BASICException => e
      @errors << e.message
      @assignment = @rest
    end
  end

  def to_s
    @keyword + ' ' + @assignment.to_s
  end

  def execute(interpreter, trace)
    r_value = first_value(interpreter)
    dims = r_value.dimensions
    values = r_value.values_1 if dims.size == 1
    values = r_value.values_2 if dims.size == 2

    l_values = @assignment.eval_target(interpreter)
    l_values.each do |l_value|
      interpreter.set_dimensions(l_value, dims)
      interpreter.set_values(l_value.name, values, trace)
    end
  end

  private

  def first_value(interpreter)
    r_values = @assignment.eval_value(interpreter)
    r_value = r_values[0]
    raise(BASICException, 'Expected Matrix') if r_value.class.to_s != 'Matrix'
    r_value
  end
end

# RANDOMIZE
class RandomizeStatement < AbstractStatement
  def initialize(line, _tokens)
    super('RANDOMIZE', line)
  end

  def to_s
    @keyword
  end

  def execute(interpreter, _)
    interpreter.new_random
  end
end
