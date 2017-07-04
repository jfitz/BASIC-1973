# Statement factory class
class StatementFactory
  def initialize
    @statement_definitions = statement_definitions
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
      all_tokens = remove_break_tokens(all_tokens)
      all_tokens = remove_whitespace_tokens(all_tokens)
      comment = nil
      comment = all_tokens.pop if
        !all_tokens.empty? && all_tokens[-1].comment?

      line = create(line_text, all_tokens, comment)
    end
    [line_number, line]
  end

  def create_statement(statement_tokens)
    if statement_tokens.empty?
      statement = EmptyStatement.new
    else
      keywords, tokens = extract_keywords(statement_tokens)
      if @statement_definitions.key?(keywords)
        tokens_lists = split_keywords(tokens)
        statement =
          @statement_definitions[keywords].new(keywords, tokens_lists)
      else
        statement = nil
      end
    end
    statement
  end

  private

  def create(text, all_tokens, comment)
    statements = []
    statements_tokens = split_on_separators(all_tokens)
    if statements_tokens.empty?
      statement = EmptyStatement.new
      statements << statement
    else
      statements_tokens.each do |statement_tokens|
        begin
          statement = create_statement(statement_tokens)
        rescue BASICException
          statement = InvalidStatement.new(text)
        end
        statement = UnknownStatement.new(text) if statement.nil?
        statements << statement
      end
    end

    Line.new(text, statements, all_tokens, comment)
  end

  def split_on_separators(tokens)
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

  def remove_break_tokens(tokens)
    new_list = []

    tokens.each do |token|
      new_list << token unless token.break?
    end

    new_list
  end

  def remove_whitespace_tokens(tokens)
    new_list = []

    tokens.each do |token|
      new_list << token unless token.whitespace?
    end

    new_list
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
    tokenizers = make_tokenizers
    invalid_tokenizer = InvalidTokenBuilder.new
    tokenizer = Tokenizer.new(tokenizers, invalid_tokenizer)
    tokenizer.tokenize(text)
  end

  def statement_definitions
    classes = [
      ArrPrintStatement,
      ArrReadStatement,
      ArrWriteStatement,
      ArrLetStatement,
      ChangeStatement,
      DataStatement,
      DefineFunctionStatement,
      DimStatement,
      EndStatement,
      FilesStatement,
      ForStatement,
      GosubStatement,
      GotoStatement,
      IfStatement,
      InputStatement,
      LetStatement,
      LetLessStatement,
      LineInputStatement,
      MatPrintStatement,
      MatReadStatement,
      MatWriteStatement,
      MatLetStatement,
      NextStatement,
      OnStatement,
      PrintStatement,
      RandomizeStatement,
      ReadStatement,
      RemarkStatement,
      RestoreStatement,
      ReturnStatement,
      StopStatement,
      TraceStatement,
      WriteStatement
    ]
    lead_keywords = {}

    classes.each do |class_name|
      keyword_sets = class_name.lead_keywords
      keyword_sets.each do |set|
        lead_keywords[set] = class_name
      end
    end

    lead_keywords
  end

  def keywords_definitions(statement_definitions)
    keys = statement_definitions.keys
    keywords = []
    keys.each do |key|
      keywords << key[0].to_s
    end
    keywords += %w(OF THEN ELSE TO STEP)
    keywords -= %w(REM REMARK)
    keywords.uniq
  end

  def make_tokenizers
    tokenizers = []

    tokenizers << CommentTokenBuilder.new
    tokenizers << RemarkTokenBuilder.new

    tokenizers << ListTokenBuilder.new(['\\', ':'], StatementSeparatorToken)

    keywords = keywords_definitions(statement_definitions)

    tokenizers << ListTokenBuilder.new(keywords, KeywordToken)

    un_ops = UnaryOperator.operators
    bi_ops = BinaryOperator.operators
    operators = (un_ops + bi_ops).uniq
    tokenizers << ListTokenBuilder.new(operators, OperatorToken)

    tokenizers << BreakTokenBuilder.new

    tokenizers << ListTokenBuilder.new(['(', '['], GroupStartToken)
    tokenizers << ListTokenBuilder.new([')', ']'], GroupEndToken)
    tokenizers << ListTokenBuilder.new([',', ';'], ParamSeparatorToken)

    tokenizers <<
      ListTokenBuilder.new(FunctionFactory.function_names, FunctionToken)

    function_names = ('FNA'..'FNZ').to_a
    tokenizers << ListTokenBuilder.new(function_names, UserFunctionToken)

    tokenizers << TextTokenBuilder.new
    tokenizers << NumberTokenBuilder.new
    tokenizers << IntegerTokenBuilder.new
    tokenizers << VariableTokenBuilder.new

    tokenizers <<
      ListTokenBuilder.new(%w(TRUE FALSE), BooleanConstantToken)

    tokenizers << WhitespaceTokenBuilder.new
  end
end

# parent of all statement classes
class AbstractStatement
  attr_reader :errors
  attr_accessor :profile_count

  def initialize(keywords, tokens_lists)
    @keywords = keywords
    @tokens_lists = tokens_lists
    @errors = []
    @modifiers = []
    modifier_added = true
    modifier_added = make_modifier(tokens_lists) while modifier_added
    @modifiers.each { |modifier| @errors += modifier.errors }
    @profile_count = 0
  end

  def pretty
    list = [AbstractToken.pretty_tokens(@keywords, @tokens_lists.flatten)]
    @modifiers.each { |modifier| list << modifier.pretty }
    list.join(' ')
  end

  def profile
    text = AbstractToken.pretty_tokens(@keywords, @tokens_lists.flatten)
    ' (' + @profile_count.to_s + ')' + text
    ### TODO: add profile for modifiers
  end

  def pre_execute(_) end

  def execute(interpreter, trace)
    current_line_index = interpreter.current_line_index
    index = current_line_index.index
    execute_premodifier(interpreter, trace) if index < 0
    execute_core(interpreter, trace) if index.zero?
    execute_postmodifier(interpreter, trace) if index > 0
  end

  def start_index
    0 - @modifiers.size
  end

  def last_index
    @modifiers.size
  end

  private

  def make_modifier(tokens_lists)
    if tokens_lists.size > 2 &&
       tokens_lists[-2] == 'IF' &&
       tokens_lists[-1].class.to_s == 'Array'

      # create the modifier
      modifier_tokens = tokens_lists[-1]
      modifier = IfModifier.new(modifier_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop
      tokens_lists.pop

      return true
    end

    if tokens_lists.size > 4 &&
       tokens_lists[-4] == 'FOR' &&
       tokens_lists[-3].class.to_s == 'Array' &&
       tokens_lists[-2] == 'TO' &&
       tokens_lists[-1].class.to_s == 'Array'

      # create the modifer
      control_and_start_tokens = tokens_lists[-3]
      end_tokens = tokens_lists[-1]
      modifier = ForModifier.new(control_and_start_tokens, end_tokens, nil)
      @modifiers << modifier

      # remove the tokens used for the modifier
      tokens_lists.pop
      tokens_lists.pop
      tokens_lists.pop
      tokens_lists.pop

      return true
    end

    if tokens_lists.size > 6 &&
       tokens_lists[-6] == 'FOR' &&
       tokens_lists[-5].class.to_s == 'Array' &&
       tokens_lists[-4] == 'TO' &&
       tokens_lists[-3].class.to_s == 'Array' &&
       tokens_lists[-2] == 'STEP' &&
       tokens_lists[-1].class.to_s == 'Array'

      # create the modifer
      control_and_start_tokens = tokens_lists[-5]
      end_tokens = tokens_lists[-3]
      step_tokens = tokens_lists[-1]
      modifier = ForModifier.new(
        control_and_start_tokens, end_tokens, step_tokens)
      @modifiers << modifier

      # remove the tokens used for the modifier
      tokens_lists.pop
      tokens_lists.pop
      tokens_lists.pop
      tokens_lists.pop
      tokens_lists.pop
      tokens_lists.pop

      return true
    end

    false
  end

  def execute_premodifier(interpreter, trace)
    current_line_index = interpreter.current_line_index
    index = 0 - (current_line_index.index + 1)
    modifier = @modifiers[index]
    modifier.execute_pre(interpreter, trace)
  end

  def execute_postmodifier(interpreter, trace)
    current_line_index = interpreter.current_line_index
    index = current_line_index.index - 1
    modifier = @modifiers[index]
    modifier.execute_post(interpreter, trace)
  end

  protected

  def check_template(tokens_lists, template)
    return false unless tokens_lists.size == template.size

    result = true
    zip = template.zip(tokens_lists)
    zip.each do |pair|
      control = pair[0]
      value = pair[1]

      case control.class.to_s
      when 'String'
        result &= (value.keyword? &&
                   value.to_s == control)
      when 'Array'
        if value.class.to_s == 'Array'
          result &= value.size == control[0] if control.size == 1
          result &= value.size >= control[0] if
            control.size == 2 && control[1] == '>='
        else
          result = false
        end
      end
    end
    result
  end

  def check_template_2(tokens_lists, template)
    return false unless tokens_lists.size >= template.size

    result = true
    zip = template.zip(tokens_lists)
    zip.each do |pair|
      control = pair[0]
      value = pair[1]

      case control.class.to_s
      when 'String'
        result &= (value.keyword? &&
                   value.to_s == control)
      when 'Array'
        result &= (value.class.to_s == 'Array')
        result &= value.size == control[0] if control.size == 1
        result &= value.size >= control[0] if
          control.size == 2 && control[1] == '>='
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

  def make_coord(c)
    [NumericConstant.new(c)]
  end

  def make_coords(r, c)
    [NumericConstant.new(r), NumericConstant.new(c)]
  end
end

# unparsed statement
class InvalidStatement < AbstractStatement
  def initialize(text)
    super([], [])
    @text = text
    @errors << 'Invalid statement'
  end

  def to_s
    @text
  end

  def execute_core(_, _)
    raise(BASICException, @errors[0])
  end

  def pre_execute(_)
    raise(BASICException, @errors[0])
  end
end

# unknown statement
class UnknownStatement < AbstractStatement
  def initialize(text)
    super([], [])
    @text = text
    @errors << "Unknown statement '#{text.strip}'"
  end

  def to_s
    @text
  end

  def execute_core(_, _) end
end

# empty statement (line number only)
class EmptyStatement < AbstractStatement
  def initialize
    super([], [])
  end

  def to_s
    ''
  end

  def execute_core(_, _)
    @profile_count += 1
  end
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
    @rest = tokens_lists[0]
  end

  def execute_core(_, _)
    @profile_count += 1
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

  def initialize(keywords, tokens_lists)
    super
    template = [[1, '>='], 'TO', [1, '=']]

    if check_template(tokens_lists, template)
      @source_tokens = tokens_lists[0]
      @target_tokens = tokens_lists[2]
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    source = ValueScalarExpression.new(@source_tokens)
    source_values = source.evaluate(interpreter)
    source_value = source_values[0]

    if source_value.text_constant?
      # string to array
      target = TargetExpression.new(@target_tokens, ArrayReference)

      array = source_value.unpack
      dims = array.dimensions
      target_variable_token = VariableToken.new(target.to_s)
      target_variable_name = VariableName.new(target_variable_token)
      target_variable = Variable.new(target_variable_name)
      interpreter.set_dimensions(target_variable, dims)
      values = array.values
      interpreter.set_values(target_variable_name, values, trace)

    elsif source_value.numeric_constant?
      # array to string
      source_variable_token = VariableToken.new(source.to_s)
      source_variable_name = VariableName.new(source_variable_token)

      target = TargetExpression.new(@target_tokens, ScalarReference)
      target_values = target.evaluate(interpreter)
      target_value = target_values[0]

      dims = interpreter.get_dimensions(source_variable_name)

      raise(BASICException, 'Source not found') if dims.nil?

      raise(BASICException, 'Source must have 1 dimension') unless
        dims.size == 1
      cols = dims[0].to_i
      values = {}
      (0..cols).each do |col|
        column = IntegerConstant.new(col)
        variable = Variable.new(source_variable_name, [column])
        coord = make_coord(col)
        values[coord] = interpreter.get_value(variable)
      end
      array = BASICArray.new(dims, values)
      text = array.pack
      interpreter.set_value(target_value, text, trace)

    else
      raise BASICException, 'Type mismatch'
    end

    @profile_count += 1
  end
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

    @expression_list = []
    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], false)
      tokens_lists.each do |tokens_list|
        begin
          @expression_list <<
            TargetExpression.new(tokens_list, VariableDimension)
        rescue BASICException
          @errors << 'Invalid variable ' + tokens_list.map(&:to_s).join
        end
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, _)
    @expression_list.each do |expression|
      variables = expression.evaluate(interpreter)
      variable = variables[0]
      subscripts = variable.subscripts
      if subscripts.empty?
        raise BASICException, 'DIM statement requires subscript range'
      end
      interpreter.set_dimensions(variable, subscripts)
    end

    @profile_count += 1
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
      @expressions = ValueScalarExpression.new(tokens_lists[0])
    else
      @errors << 'Syntax error'
    end
  end

  def pre_execute(interpreter)
    file_names = @expressions.evaluate(interpreter)
    interpreter.add_file_names(file_names)

    @profile_count += 1
  end

  def execute_core(_, _) end
end

# GOTO
class GotoStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('GOTO')],
      [KeywordToken.new('GOT')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template1 = [[1]]
    template2 = [[1, '>='], 'OF', [1, '>=']]
    @destination = nil
    @destinations = nil

    if check_template(tokens_lists, template1)
      if tokens_lists[0][0].numeric_constant?
        @destination = LineNumber.new(tokens_lists[0][0])
      else
        @errors << "Invalid line number #{tokens_lists[0][0]}"
      end
    elsif check_template(tokens_lists, template2)
      expression = tokens_lists[0]
      begin
        @expression = ValueScalarExpression.new(expression)
      rescue BASICException => e
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
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    unless @destination.nil?
      line_number = @destination
      index = interpreter.statement_start_index(line_number, 0)
      raise(BASICException, 'Line number not found') if index.nil?
      destination = LineNumberIndex.new(line_number, 0, index)
      interpreter.next_line_index = destination
    end

    unless @destinations.nil?
      values = @expression.evaluate(interpreter)
      raise(BASICException, 'Expecting one value') unless values.size == 1
      value = values[0]
      raise(BASICException, 'Invalid value') unless
        value.numeric_constant?
      puts ' ' + @expression.to_s + ' = ' + value.to_s if trace
      index = value.to_i
      raise(BASICException, 'Index out of range') if
        index < 1 || index > @destinations.size
      # get destination in list
      line_number = @destinations[index - 1]
      index = interpreter.statement_start_index(line_number, 0)
      raise(BASICException, 'Line number not found') if index.nil?
      destination = LineNumberIndex.new(line_number, 0, index)
      interpreter.next_line_index = destination
    end

    @profile_count += 1
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
    template = [[1]]

    if check_template(tokens_lists, template)
      if tokens_lists[0][0].numeric_constant?
        @destination = LineNumber.new(tokens_lists[0][0])
      else
        @errors << "Invalid line number #{tokens_lists[0][0]}"
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, _)
    line_number = @destination
    index = interpreter.statement_start_index(line_number, 0)
    raise(BASICException, 'Line number not found') if index.nil?
    destination = LineNumberIndex.new(line_number, 0, index)
    interpreter.push_return(interpreter.next_line_index)
    interpreter.next_line_index = destination

    @profile_count += 1
  end
end

# LET
class LetStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('LET')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template = [[3, '>=']]

    if check_template(tokens_lists, template)
      begin
        @assignment = ScalarAssignment.new(tokens_lists[0])
        if @assignment.count_target.zero?
          @errors << 'Assignment must have left-hand value(s)'
        end
        if @assignment.count_value != 1
          @errors << 'Assignment must have only one right-hand value'
        end
      rescue BASICException => e
        @errors << e.message
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    l_values = @assignment.eval_target(interpreter)
    r_values = @assignment.eval_value(interpreter)
    r_value = r_values[0]
    l_values.each do |l_value|
      interpreter.set_value(l_value, r_value, trace)
    end

    @profile_count += 1
  end
end

# LET-less assignment
class LetLessStatement < AbstractStatement
  def self.lead_keywords
    [
      []
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template = [[3, '>=']]

    if check_template(tokens_lists, template)
      begin
        @assignment = ScalarAssignment.new(tokens_lists[0])
        if @assignment.count_target.zero?
          @errors << 'Assignment must have left-hand value(s)'
        end
        if @assignment.count_value != 1
          @errors << 'Assignment must have only one right-hand value'
        end
      rescue BASICException => e
        @errors << e.message
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    l_values = @assignment.eval_target(interpreter)
    r_values = @assignment.eval_value(interpreter)
    r_value = r_values[0]
    l_values.each do |l_value|
      interpreter.set_value(l_value, r_value, trace)
    end

    @profile_count += 1
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

  def initialize(keywords, tokens_lists)
    super
    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      @input_items = split_tokens(tokens_lists[0], false)
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    default_prompt = TextConstantToken.new('"? "')
    prompt = default_prompt
    input_items = @input_items.clone
    begin
      value = first_value(input_items, interpreter)
      if value.class.to_s == 'FileHandle'
        fh = value
        input_items.shift
        value = first_value(input_items, interpreter)
      end
      token = first_token(input_items)
      if token.text_constant?
        prompt = value
        input_items.shift
      end
    rescue BASICException
      fh = nil
    end
    expression_list = []
    input_items.each do |items_list|
      begin
        expression_list << TargetExpression.new(items_list, ScalarReference)
      rescue BASICException
        raise(BASICException,
              'Invalid variable ' + items_list.map(&:to_s).join)
      end
    end
    if fh.nil?
      io = interpreter.console_io
      values =
        input_values(interpreter, prompt, default_prompt, expression_list.size)
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

    @profile_count += 1
  end

  private

  def first_token(input_items)
    input_items[0][0]
  end

  def first_value(input_items, interpreter)
    first_list = input_items[0]
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
  def self.lead_keywords
    [
      [KeywordToken.new('IF')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super

    if tokens_lists.class.to_s == 'Hash'
      @expression = parse_expression(tokens_lists['expr'])
      @destination, @statement = parse_target(tokens_lists['then'])
      @else_dest = nil
      @else_dest, @else_stmt = parse_target(tokens_lists['else']) if
        tokens_lists.key?('else')
    else
      begin
        stack = parse_if(tokens_lists)
        @expression = parse_expression(stack['expr'])
        @destination, @statement = parse_target(stack['then'])
        @else_dest = nil
        @else_dest, @else_stmt = parse_target(stack['else']) if
          stack.key?('else')
      rescue
        @errors << 'Syntax Error'
      end
    end
  end

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
            dict['then' ] = new_dict
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
            raise(BASICException, 'Syntax Error')
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

  def execute_core(interpreter, trace)
    io = interpreter.console_io
    s = ' ' + @expression.to_s
    io.trace_output(s) if trace
    values = @expression.evaluate(interpreter)
    raise(BASICException, 'Expression error') unless
      values.size == 1
    result = values[0]
    raise(BASICException, 'Expression error') unless
      result.class.to_s == 'BooleanConstant'
    if result.value
      if !@destination.nil?
        line_number = @destination
        index = interpreter.statement_start_index(line_number, 0)
        raise(BASICException, 'Line number not found') if index.nil?
        destination = LineNumberIndex.new(line_number, 0, index)
        interpreter.next_line_index = destination
      end

      @statement.execute(interpreter, trace) if !@statement.nil?
    else
      if !@else_dest.nil?
        line_number = @else_dest
        index = interpreter.statement_start_index(line_number, 0)
        raise(BASICException, 'Line number not found') if index.nil?
        destination = LineNumberIndex.new(line_number, 0, index)
        interpreter.next_line_index = destination
      end

      if @else_dest.nil? && @else_stmt.nil? && interpreter.if_false_next_line
        # go to next numbered line, not next statement
        next_line_index = interpreter.find_next_line
        interpreter.next_line_index = next_line_index
      end

      @else_stmt.execute(interpreter, trace) if !@else_stmt.nil?
    end
    return unless trace
    s = ' ' + result.to_s
    io.trace_output(s)

    @profile_count += 1
  end

  private

  def parse_expression(tokens)
    expression = nil
    begin
      expression = ValueScalarExpression.new(tokens)
    rescue BASICException => e
      @errors << e.message
    end
    expression
  end

  def parse_target(tokens)
    destination = nil
    statement = nil
    if tokens.class.to_s == 'Hash'
      statement = IfStatement.new(nil, tokens)
    elsif tokens.size == 1 && tokens[0].numeric_constant?
      destination = LineNumber.new(tokens[0])
    else
      statement_factory = StatementFactory.new
      statement = statement_factory.create_statement(tokens.flatten)
      @errors += statement.errors
    end
    [destination, statement]
  end
end

# LINE INPUT
class LineInputStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('LINE'), KeywordToken.new('INPUT')],
      [KeywordToken.new('LINPUT')],
      [KeywordToken.new('LIN')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      @input_items = split_tokens(tokens_lists[0], false)
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    default_prompt = TextConstantToken.new('"? "')
    prompt = default_prompt
    input_items = @input_items.clone
    begin
      value = first_value(input_items, interpreter)
      if value.class.to_s == 'FileHandle'
        fh = value
        input_items.shift
        value = first_value(input_items, interpreter)
      end
      token = first_token(input_items)
      if token.text_constant?
        prompt = value
        input_items.shift
      end
    rescue BASICException
      fh = nil
    end
    expression_list = []
    input_items.each do |items_list|
      begin
        expression_list << TargetExpression.new(items_list, ScalarReference)
      rescue BASICException
        raise(BASICException,
              'Invalid variable ' + items_list.map(&:to_s).join)
      end
    end
    if fh.nil?
      io = interpreter.console_io
      values =
        input_values(interpreter, prompt, default_prompt, expression_list.size)
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

    @profile_count += 1
  end

  private

  def first_token(input_items)
    input_items[0][0]
  end

  def first_value(input_items, interpreter)
    first_list = input_items[0]
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
      values += io.line_input(interpreter)

      prompt = default_prompt
    end
    values
  end

  def file_values(interpreter, fh)
    values = []
    io = interpreter.get_input(fh)
    values += io.line_input(interpreter)
    values
  end
end

# common for PRINT, ARR PRINT, MAT PRINT
class AbstractPrintStatement < AbstractStatement
  def initialize(keywords, tokens_lists, final_carriage)
    super(keywords, tokens_lists)
    @final = final_carriage
  end

  def extract_file_handle(print_items, interpreter)
    print_items = print_items.clone
    file_handle = nil
    unless print_items.empty? ||
           print_items[0].class.to_s == 'CarriageControl'
      value = first_item(print_items, interpreter)
      if value.class.to_s == 'FileHandle'
        file_handle = value
        print_items.shift
        print_items.shift if
          print_items[0].class.to_s == 'CarriageControl'
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
  def self.lead_keywords
    [
      [KeywordToken.new('PRINT')],
      [KeywordToken.new('PRI')],
      [KeywordToken.new('&')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super(keywords, tokens_lists, CarriageControl.new('NL'))
    template1 = []
    template2 = [[1, '>=']]

    if check_template(tokens_lists, template1)
      @print_items = tokens_to_expressions([])
    elsif check_template(tokens_lists, template2)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @print_items = tokens_to_expressions(tokens_lists)
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, _)
    file_handle, print_items = extract_file_handle(@print_items, interpreter)
    fh = interpreter.get_file_handler(file_handle)
    print_items.each do |item|
      item.print(fh, interpreter)
    end

    @profile_count += 1
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
    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def execute_core(interpreter, _)
    interpreter.next_line_index = interpreter.pop_return

    @profile_count += 1
  end
end

# ON GOTO
class OnStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ON')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template1 = [[1, '>='], 'GOTO', [1, '>=']]
    template2 = [[1, '>='], 'THEN', [1, '>=']]

    if check_template(tokens_lists, template1) ||
       check_template(tokens_lists, template2)
      expression = tokens_lists[0]
      begin
        @expression = ValueScalarExpression.new(expression)
      rescue BASICException => e
        @errors << e.message
      end
      destinations = tokens_lists[2]
      line_nums = split_tokens(destinations, false)
      @destinations = []
      line_nums.each do |line_num|
        if line_num.size == 1
          destination = line_num[0]
          if destination.numeric_constant?
            line_number = LineNumber.new(destination)
            @destinations << line_number
          else
            @errors << "Invalid line number #{destination}"
          end
        else
          @errors << "Invalid line specification #{line_num}"
        end
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    values = @expression.evaluate(interpreter)
    raise(BASICException, 'Expecting one value') unless values.size == 1
    value = values[0]
    raise(BASICException, 'Invalid value') unless value.numeric_constant?
    puts ' ' + @expression.to_s + ' = ' + value.to_s if trace
    index = value.to_i
    raise(BASICException, 'Index out of range') if
      index < 1 || index > @destinations.size
    # get destination in list
    line_number = @destinations[index - 1]
    index = interpreter.statement_start_index(line_number, 0)
    raise(BASICException, 'Line number not found') if index.nil?
    destination = LineNumberIndex.new(line_number, 0, index)
    interpreter.next_line_index = destination

    @profile_count += 1
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
  def self.lead_keywords
    [
      [KeywordToken.new('FOR')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template1 = [[1, '>='], 'TO', [1, '>=']]
    template2 = [[1, '>='], 'TO', [1, '>='], 'STEP', [1, '>=']]

    if check_template(tokens_lists, template1)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        @control = VariableName.new(tokens1[0])
        @start = ValueScalarExpression.new(tokens2)
        @end = ValueScalarExpression.new(tokens_lists[2])
        @step_value = ValueScalarExpression.new([NumericConstantToken.new(1)])
      rescue BASICException => e
        @errors << e.message
      end
    elsif check_template(tokens_lists, template2)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        @control = VariableName.new(tokens1[0])
        @start = ValueScalarExpression.new(tokens2)
        @end = ValueScalarExpression.new(tokens_lists[2])
        @step_value = ValueScalarExpression.new(tokens_lists[4])
      rescue BASICException => e
        @errors << e.message
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    from = @start.evaluate(interpreter)[0]
    to = @end.evaluate(interpreter)[0]
    step = @step_value.evaluate(interpreter)[0]

    interpreter.set_value(@control, from, false)
    fornext_control =
      ForNextControl.new(@control,
                         interpreter.next_line_index, from, to, step)

    interpreter.assign_fornext(fornext_control)
    terminated = fornext_control.front_terminated?
    if terminated
      interpreter.next_line_index =
        interpreter.find_closing_next(@control)
    end

    io = interpreter.console_io
    print_trace_info(io, from, to, step, terminated) if
      trace

    @profile_count += 1
  end

  private

  def control_and_start(tokens)
    parts = split_on_token(tokens, '=')
    raise(BASICException, 'Incorrect initialization') if
      parts.size != 3
    raise(BASICException, 'Incorrect initialization') if
      parts[1].to_s != '='

    @errors << 'Control variable must be a variable' unless
      parts[0][0].variable?

    [parts[0], parts[2]]
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
        @control = VariableName.new(tokens_lists[0][0])
      else
        @errors << "Invalid control variable #{tokens_lists[0][0]}"
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    fornext_control = interpreter.retrieve_fornext(@control)
    # check control variable value
    # if matches end value, stop here
    terminated = fornext_control.terminated?(interpreter)
    if trace
      io = interpreter.console_io
      s = ' terminated:' + terminated.to_s
      io.trace_output(s)
    end

    @profile_count += 1

    return if terminated

    # set next line from top item
    interpreter.next_line_index = fornext_control.start_line_index
    # change control variable value
    fornext_control.bump_control(interpreter, trace)
  end
end

# common for READ, ARR READ, MAT READ
class AbstractReadStatement < AbstractStatement
  def initialize(keywords, tokens_lists)
    super
  end

  private

  def extract_file_handle(tokens_lists, interpreter)
    tokens_lists = tokens_lists.clone
    begin
      unless tokens_lists.empty? ||
             tokens_lists[0].class.to_s == 'CarriageControl'
        value = first_value(tokens_lists, interpreter)
        if value.class.to_s == 'FileHandle'
          file_handle = value
          tokens_lists.shift
          tokens_lists.shift if tokens_lists[0].class.to_s == 'CarriageControl'
        end
      end
    rescue BASICException
      file_handle = nil
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
  def self.lead_keywords
    [
      [KeywordToken.new('READ')],
      [KeywordToken.new('REA')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      @read_items = split_tokens(tokens_lists[0], false)
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    read_items = @read_items.clone
    unless read_items.empty?
      fh, tokens_lists = extract_file_handle(read_items, interpreter)
    end
    expression_list = []
    tokens_lists.each do |tokens_list|
      begin
        expression_list << TargetExpression.new(tokens_list, ScalarReference)
      rescue BASICException
        raise(BASICException,
              'Invalid variable ' + tokens_list.map(&:to_s).join)
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

    @profile_count += 1
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
    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      @expressions = ValueScalarExpression.new(tokens_lists[0])
    else
      @errors << 'Syntax error'
    end
  end

  def pre_execute(interpreter)
    ds = interpreter.get_data_store(nil)
    data_list = @expressions.evaluate(interpreter)
    ds.store(data_list)

    @profile_count += 1
  end

  def execute_core(_, _) end
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
    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def execute_core(interpreter, _)
    ds = interpreter.get_data_store(nil)
    ds.reset

    @profile_count += 1
  end
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
      @name = ''
      @arguments = []
      @template = ''
      begin
        user_function_definition = UserFunctionDefinition.new(tokens_lists[0])
        @name = user_function_definition.name
        @arguments = user_function_definition.arguments
        @template = user_function_definition.template
      rescue BASICException => e
        puts e.message
        @errors << e.message
      end
    else
      @errors << 'Syntax error'
    end
  end

  def pre_execute(interpreter)
    interpreter.set_user_function(@name, @arguments, @template)

    @profile_count += 1
  end

  def execute_core(_, _) end
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
    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def execute_core(interpreter, _)
    io = interpreter.console_io
    io.newline_when_needed
    interpreter.stop

    @profile_count += 1
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
    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def pre_execute(interpreter)
    next_line = interpreter.find_next_line_index
    raise(BASICException, 'Statements after END') unless next_line.nil?

    @profile_count += 1
  end

  def execute_core(interpreter, _)
    io = interpreter.console_io
    io.newline_when_needed
    interpreter.stop

    @profile_count += 1
  end
end

# TRACE
class TraceStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('TRACE')],
      [KeywordToken.new('TRA')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      @tokens_lists = split_tokens(tokens_lists[0], false)
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, _)
    tokens_lists = @tokens_lists.clone
    raise(BASICException, 'Too many values') if tokens_lists.size > 1
    first_expression = tokens_lists[0]
    expression = ValueScalarExpression.new(first_expression)
    values = expression.evaluate(interpreter)
    value = values[0]
    interpreter.trace(value.to_v)

    @profile_count += 1
  end
end

# common for WRITE, ARR WRITE, MAT WRITE
class AbstractWriteStatement < AbstractStatement
  def initialize(keywords, tokens_lists, final_carriage)
    super(keywords, tokens_lists)
    @final = final_carriage
  end

  def extract_file_handle(print_items, interpreter)
    print_items = print_items.clone
    file_handle = nil
    unless print_items.empty? ||
           print_items[0].class.to_s == 'CarriageControl'
      value = first_item(print_items, interpreter)
      if value.class.to_s == 'FileHandle'
        file_handle = value
        print_items.shift
        print_items.shift if
          print_items[0].class.to_s == 'CarriageControl'
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

# WRITE
class WriteStatement < AbstractWriteStatement
  def self.lead_keywords
    [
      [KeywordToken.new('WRITE')],
      [KeywordToken.new('WRI')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super(keywords, tokens_lists, CarriageControl.new('NL'))
    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @print_items = tokens_to_expressions(tokens_lists)
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, _)
    file_handle, print_items = extract_file_handle(@print_items, interpreter)
    fh = interpreter.get_file_handler(file_handle)
    print_items.each do |item|
      item.write(fh, interpreter)
    end

    @profile_count += 1
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

# ARR PRINT
class ArrPrintStatement < AbstractPrintStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('PRINT')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super(keywords, tokens_lists, CarriageControl.new(','))
    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @print_items = tokens_to_expressions(tokens_lists)
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, _)
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

    @profile_count += 1
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

# ARR WRITE
class ArrWriteStatement < AbstractWriteStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('WRITE')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super(keywords, tokens_lists, CarriageControl.new(','))
    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @print_items = tokens_to_expressions(tokens_lists)
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, _)
    file_handle, print_items = extract_file_handle(@print_items, interpreter)
    fh = interpreter.get_file_handler(file_handle)
    i = 0
    print_items.each do |item|
      if item.printable?
        carriage = CarriageControl.new('')
        carriage = print_items[i + 1] if
          i < print_items.size &&
          !print_items[i + 1].printable?
        item.write(fh, interpreter, carriage)
      end
      i += 1
    end

    @profile_count += 1
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

# MAT WRITE
class MatWriteStatement < AbstractWriteStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('WRITE')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super(keywords, tokens_lists, CarriageControl.new(','))
    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @print_items = tokens_to_expressions(tokens_lists)
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, _)
    file_handle, print_items = extract_file_handle(@print_items, interpreter)
    fh = interpreter.get_file_handler(file_handle)
    i = 0
    print_items.each do |item|
      if item.printable?
        carriage = CarriageControl.new('')
        carriage = print_items[i + 1] if
          i < print_items.size &&
          !print_items[i + 1].printable?
        item.write(fh, interpreter, carriage)
      end
      i += 1
    end

    @profile_count += 1
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

# ARR READ
class ArrReadStatement < AbstractReadStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('READ')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      @read_items = split_tokens(tokens_lists[0], false)
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    tokens_lists = @read_items.clone
    unless tokens_lists.empty?
      fh, tokens_lists = extract_file_handle(tokens_lists, interpreter)
    end
    expression_list = []
    tokens_lists.each do |tokens_list|
      begin
        expression = TargetExpression.new(tokens_list, ArrayReference)
        expression_list << expression
      rescue BASICException
        raise(BASICException,
              'Invalid variable ' + tokens_list.map(&:to_s).join)
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

    @profile_count += 1
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
  def self.lead_keywords
    [
      [KeywordToken.new('ARR')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template = [[3, '>=']]

    if check_template(tokens_lists, template)
      begin
        @assignment = ArrayAssignment.new(tokens_lists[0])
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
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    r_value = first_value(interpreter)
    dims = r_value.dimensions
    values = r_value.values

    l_values = @assignment.eval_target(interpreter)
    l_values.each do |l_value|
      interpreter.set_dimensions(l_value, dims)
      interpreter.set_values(l_value.name, values, trace)
    end

    @profile_count += 1
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
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('PRINT')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super(keywords, tokens_lists, CarriageControl.new(','))
    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @print_items = tokens_to_expressions(tokens_lists)
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, _)
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

    @profile_count += 1
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
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('READ')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      @read_items = split_tokens(tokens_lists[0], false)
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    tokens_lists = @read_items.clone
    unless tokens_lists.empty?
      fh, tokens_lists = extract_file_handle(tokens_lists, interpreter)
    end
    expression_list = []
    tokens_lists.each do |tokens_list|
      begin
        expression = TargetExpression.new(tokens_list, MatrixReference)
        expression_list << expression
      rescue BASICException
        raise(BASICException,
              'Invalid variable ' + tokens_list.map(&:to_s).join)
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

    @profile_count += 1
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
  def self.lead_keywords
    [
      [KeywordToken.new('MAT')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template = [[3, '>=']]

    if check_template(tokens_lists, template)
      begin
        @assignment = MatrixAssignment.new(tokens_lists[0])
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
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter, trace)
    r_value = first_value(interpreter)
    dims = r_value.dimensions
    values = r_value.values_1 if dims.size == 1
    values = r_value.values_2 if dims.size == 2

    l_values = @assignment.eval_target(interpreter)
    l_values.each do |l_value|
      interpreter.set_dimensions(l_value, dims)
      interpreter.set_values(l_value.name, values, trace)
    end

    @profile_count += 1
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
  def self.lead_keywords
    [
      [KeywordToken.new('RANDOMIZE')],
      [KeywordToken.new('RANDOM')],
      [KeywordToken.new('RAN')]
    ]
  end

  def initialize(keywords, tokens_lists)
    super
    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def execute_core(interpreter, _)
    interpreter.new_random

    @profile_count += 1
  end
end
