# Modifier
class AbstractModifier
  def self.extra_keywords
    []
  end

  attr_reader :errors
  attr_reader :numerics
  attr_reader :strings
  attr_reader :booleans
  attr_reader :variables
  attr_reader :operators
  attr_reader :functions
  attr_reader :userfuncs
  attr_reader :comprehension_effort

  def initialize
    @errors = []
  end

  private

  def parse_expression(expression_tokens)
    expression = nil

    begin
      expression = ValueExpression.new(expression_tokens, :scalar)
    rescue BASICExpressionError => e
      @errors << e.message
    end

    expression
  end

  # get opposite modifier (pre- when in post; post- when in pre)
  def get_counterpart(interpreter)
    current_line_index = interpreter.current_line_index
    number = current_line_index.number
    statement_index = current_line_index.statement
    index = current_line_index.index
    other_index = -index
    LineNumberIndex.new(number, statement_index, other_index)
  end
end

# IF
class IfModifier < AbstractModifier
  def self.lead_keywords
    [
      [KeywordToken.new('IF')]
    ]
  end

  def initialize(expression_tokens)
    super()

    @expression = parse_expression(expression_tokens)
    @numerics = @expression.numerics
    @strings = @expression.strings
    @booleans = @expression.booleans
    @variables = @expression.variables
    @operators = @expression.operators
    @functions = @expression.functions
    @userfuncs = @expression.userfuncs
    @comprehension_effort = @expression.comprehension_effort
  end

  def pretty
    'IF ' + @expression.to_s
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?
    lines += @statement.dump unless @statement.nil?
    lines += @else_stmt.dump unless @else_stmt.nil?

    lines
  end

  def pre_trace
    ' IF ' + @expression.to_s
  end

  def post_trace
    ' ENDIF'
  end

  def execute_pre(interpreter)
    io = interpreter.trace_out

    values = @expression.evaluate(interpreter)
    raise(BASICExpressionError, 'Too many values') unless
      values.size == 1

    result = values[0]
    result = BooleanConstant.new(result) unless
      result.class.to_s == 'BooleanConstant'

    s = ' ' + result.to_s
    io.trace_output(s)

    # if true then continue execution normally
    return if result.value

    # if false then transfer to our post modifier
    interpreter.next_line_index = get_counterpart(interpreter)
  end

  def execute_post(_) end
end

# UNLESS
class UnlessModifier < AbstractModifier
  def self.lead_keywords
    [
      [KeywordToken.new('UNLESS')]
    ]
  end

  def initialize(expression_tokens)
    super()
    
    @expression = parse_expression(expression_tokens)
    @numerics = @expression.numerics
    @strings = @expression.strings
    @booleans = @expression.booleans
    @variables = @expression.variables
    @operators = @expression.operators
    @functions = @expression.functions
    @userfuncs = @expression.userfuncs
    @comprehension_effort = @expression.comprehension_effort
  end

  def pretty
    'UNLESS ' + @expression.to_s
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?
    lines += @statement.dump unless @statement.nil?
    lines += @else_stmt.dump unless @else_stmt.nil?

    lines
  end

  def pre_trace
    ' UNLESS ' + @expression.to_s
  end

  def post_trace
    ' ENDUNLESS'
  end

  def execute_pre(interpreter)
    io = interpreter.trace_out

    values = @expression.evaluate(interpreter)
    raise(BASICExpressionError, 'Too many values') unless
      values.size == 1

    result = values[0]
    result = BooleanConstant.new(result) unless
      result.class.to_s == 'BooleanConstant'

    s = ' ' + result.to_s
    io.trace_output(s)

    # if false then continue execution normally
    return unless result.value

    # if true then transfer to our post modifier
    interpreter.next_line_index = get_counterpart(interpreter)
  end

  def execute_post(_) end

  private
end

# WHILE
class WhileModifier < AbstractModifier
  def self.lead_keywords
    [
      [KeywordToken.new('WHILE')]
    ]
  end

  def initialize(expression_tokens)
    super()
    
    @expression = parse_expression(expression_tokens)
    @numerics = @expression.numerics
    @strings = @expression.strings
    @booleans = @expression.booleans
    @variables = @expression.variables
    @operators = @expression.operators
    @functions = @expression.functions
    @userfuncs = @expression.userfuncs
    @comprehension_effort = @expression.comprehension_effort
  end

  def pretty
    'WHILE ' + @expression.to_s
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?
    lines += @statement.dump unless @statement.nil?
    lines += @else_stmt.dump unless @else_stmt.nil?

    lines
  end

  def pre_trace
    ' WHILE ' + @expression.to_s
  end

  def post_trace
    ' ENDWHILE'
  end

  def execute_pre(interpreter)
    io = interpreter.trace_out

    values = @expression.evaluate(interpreter)
    raise(BASICExpressionError, 'Too many values') unless
      values.size == 1

    result = values[0]
    result = BooleanConstant.new(result) unless
      result.class.to_s == 'BooleanConstant'

    s = ' ' + result.to_s
    io.trace_output(s)

    # if not terminated then continue execution normally
    return if result.value

    # if terminated then transfer to our post modifier
    interpreter.next_line_index = get_counterpart(interpreter)
  end

  def execute_post(interpreter)
    io = interpreter.trace_out

    values = @expression.evaluate(interpreter)
    raise(BASICExpressionError, 'Too many values') unless
      values.size == 1

    result = values[0]
    result = BooleanConstant.new(result) unless
      result.class.to_s == 'BooleanConstant'

    s = ' ' + result.to_s
    io.trace_output(s)

    # if terminated then continue to next statement
    return unless result.value

    # if not terminated then go to start of while
    interpreter.next_line_index = get_counterpart(interpreter)
  end
end

# UNTIL
class UntilModifier < AbstractModifier
  def self.lead_keywords
    [
      [KeywordToken.new('UNTIL')]
    ]
  end

  def initialize(expression_tokens)
    super()
    
    @expression = parse_expression(expression_tokens)
    @numerics = @expression.numerics
    @strings = @expression.strings
    @booleans = @expression.booleans
    @variables = @expression.variables
    @operators = @expression.operators
    @functions = @expression.functions
    @userfuncs = @expression.userfuncs
    @comprehension_effort = @expression.comprehension_effort
  end

  def pretty
    'UNTIL ' + @expression.to_s
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?
    lines += @statement.dump unless @statement.nil?
    lines += @else_stmt.dump unless @else_stmt.nil?

    lines
  end

  def pre_trace
    ' UNTIL ' + @expression.to_s
  end

  def post_trace
    ' ENDUNTIL'
  end

  def execute_pre(interpreter)
    io = interpreter.trace_out

    values = @expression.evaluate(interpreter)
    raise(BASICExpressionError, 'Too many values') unless
      values.size == 1

    result = values[0]
    result = BooleanConstant.new(result) unless
      result.class.to_s == 'BooleanConstant'

    s = ' ' + result.to_s
    io.trace_output(s)

    # if terminated then continue execution normally
    return unless result.value

    # if not terminated then transfer to our post modifier
    interpreter.next_line_index = get_counterpart(interpreter)
  end

  def execute_post(interpreter)
    io = interpreter.trace_out

    values = @expression.evaluate(interpreter)
    raise(BASICExpressionError, 'Too many values') unless
      values.size == 1

    result = values[0]
    result = BooleanConstant.new(result) unless
      result.class.to_s == 'BooleanConstant'

    s = ' ' + result.to_s
    io.trace_output(s)

    # if not terminated then continue to next statement
    return if result.value

    # if terminated then go to start of until
    interpreter.next_line_index = get_counterpart(interpreter)
  end
end

# FOR
class ForModifier < AbstractModifier
  def self.lead_keywords
    [
      [KeywordToken.new('FOR')]
    ]
  end

  def self.extra_keywords
    %w[TO STEP UNTIL]
  end

  def initialize(control_and_start_tokens, step_tokens, end_tokens, until_tokens, while_tokens)
    super()
    
    parts = split_on_token(control_and_start_tokens, '=')

    raise(BASICSyntaxError, 'Incorrect initialization') if
      parts.size != 3

    raise(BASICSyntaxError, 'Missing "=" sign') if
      parts[1].to_s != '='

    control_tokens = parts[0]
    start_tokens = parts[2]

    @errors << 'Control variable must be a variable' unless
      control_tokens.class.to_s == 'Array' &&
      !control_tokens.empty? &&
      control_tokens[0].variable?

    control_name = VariableName.new(control_tokens[0])
    @control = Variable.new(control_name, :scalar, [])
    @start = ValueExpression.new(start_tokens, :scalar)
    @step = ValueExpression.new(step_tokens, :scalar) unless step_tokens.nil?
    @end = ValueExpression.new(end_tokens, :scalar) unless end_tokens.nil?
    @until = ValueExpression.new(until_tokens, :scalar) unless until_tokens.nil?
    @while = ValueExpression.new(while_tokens, :scalar) unless while_tokens.nil?

    control = XrefEntry.new(@control.to_s, nil, true)

    @numerics = @start.numerics
    @strings = @start.strings
    @booleans = @start.booleans
    @variables = [control] + @start.variables
    @operators = @start.operators
    @functions = @start.functions
    @userfuncs = @start.userfuncs

    if !@end.nil?
      @numerics += @end.numerics
      @strings += @end.strings
      @booleans += @end.booleans
      @variables += @end.variables
      @operators += @end.operators
      @functions += @end.functions
      @userfuncs += @end.userfuncs
    end

    if !@step.nil?
      @numerics += @step.numerics
      @strings += @step.strings
      @booleans += @step.booleans
      @variables += @step.variables
      @operators += @step.operators
      @functions += @step.functions
      @userfuncs += @step.userfuncs
    end

    if !@until.nil?
      @numerics += @until.numerics
      @strings += @until.strings
      @booleans += @until.booleans
      @variables += @until.variables
      @operators += @until.operators
      @functions += @until.functions
      @userfuncs += @until.userfuncs
    end

    if !@while.nil?
      @numerics += @while.numerics
      @strings += @while.strings
      @booleans += @while.booleans
      @variables += @while.variables
      @operators += @while.operators
      @functions += @while.functions
      @userfuncs += @while.userfuncs
    end

    @comprehension_effort = @start.comprehension_effort
    @comprehension_effort += @end.comprehension_effort unless @end.nil?
    @comprehension_effort += @step.comprehension_effort unless @step.nil?
    @comprehension_effort += @until.comprehension_effort unless @until.nil?
    @comprehension_effort += @while.comprehension_effort unless @while.nil?
  end

  def pretty
    if !@end.nil?
      if @step.nil?
        "FOR #{@control} = #{@start} TO #{@end}"
      else
        "FOR #{@control} = #{@start} TO #{@end} STEP #{@step}"
      end
    end

    if !@until.nil?
      if @step.nil?
        "FOR #{@control} = #{@start} UNTIL #{@until}"
      else
        "FOR #{@control} = #{@start} UNTIL #{@until} STEP #{@step}"
      end
    end

    if !@while.nil?
      if @step.nil?
        "FOR #{@control} = #{@start} WHILE #{@while}"
      else
        "FOR #{@control} = #{@start} WHILE #{@while} STEP #{@step}"
      end
    end
  end

  def dump
    lines = []
    lines << 'control: ' + @control.dump unless @control.nil?
    lines << 'start:   ' + @start.dump.to_s unless @start.nil?
    lines << 'end:     ' + @end.dump.to_s unless @end.nil?
    lines << 'step:    ' + @step.dump.to_s unless @step.nil?
    lines << 'until:   ' + @until.dump.to_s unless @until.nil?
    lines << 'while:   ' + @while.dump.to_s unless @while.nil?
    lines
  end

  def pre_trace
    # notice that this output differs from pretty()
    # we have a leading space here

    s = ''

    if !@end.nil?
      if @step.nil?
        s = " FOR #{@control} = #{@start} TO #{@end}"
      else
        s = " FOR #{@control} = #{@start} TO #{@end} STEP #{@step}"
      end
    end

    if !@until.nil?
      if @step.nil?
        s = " FOR #{@control} = #{@start} UNTIL #{@until}"
      else
        s = " FOR #{@control} = #{@start} UNTIL #{@until} STEP #{@step}"
      end
    end

    if !@while.nil?
      if @step.nil?
        s = " FOR #{@control} = #{@start} UNTIL #{@while}"
      else
        s = " FOR #{@control} = #{@start} UNTIL #{@while} STEP #{@step}"
      end
    end

    s
  end

  def post_trace
    " NEXT #{@control}"
  end

  def execute_pre(interpreter)
    from = @start.evaluate(interpreter)[0]
    step = NumericConstant.new(1)
    step = @step.evaluate(interpreter)[0] unless @step.nil?

    if !@end.nil?
      to = @end.evaluate(interpreter)[0]
      fornext_control = ForToControl.new(@control, from, step, to)
    end

    if !@until.nil?
      fornext_control = ForUntilControl.new(@control, from, step, @until)
    end

    if !@while.nil?
      fornext_control = ForWhileControl.new(@control, from, step, @while)
    end

    interpreter.assign_fornext(fornext_control)

    interpreter.lock_variable(@control) if $options['lock_fornext'].value
    interpreter.enter_fornext(@control)

    terminated = fornext_control.front_terminated?(interpreter)

    io = interpreter.trace_out
    print_trace_info(io, terminated)

    return unless terminated

    # front-terminated; go to post-exec of this modifier
    interpreter.unlock_variable(@control) if $options['lock_fornext'].value

    interpreter.next_line_index = get_counterpart(interpreter)
  end

  def execute_post(interpreter)
    fornext_control = interpreter.retrieve_fornext(@control)

    bump_early = fornext_control.bump_early?
    
    # change control variable value for FOR-WHILE and FOR-UNTIL
    fornext_control.bump_control(interpreter) if bump_early

    terminated = fornext_control.terminated?(interpreter)
    io = interpreter.trace_out
    print_trace_info(io, terminated)

    if terminated
      interpreter.unlock_variable(@control) if $options['lock_fornext'].value
      interpreter.exit_fornext(fornext_control.forget, fornext_control.control)
    else
      # set next line from top item
      interpreter.next_line_index = fornext_control.loop_start_index
      # change control variable value
      fornext_control.bump_control(interpreter) unless bump_early
    end
  end

  private

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

  def print_trace_info(io, terminated)
    io.trace_output(" terminated:#{terminated}")
  end
end
