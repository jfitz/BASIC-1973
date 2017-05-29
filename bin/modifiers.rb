# IF
class IfModifier
  attr_reader :errors

  def initialize(expression_tokens)
    @errors = []
    @expression = parse_expression(expression_tokens)
  end

  def to_s
    'IF ' + @expression.to_s
  end

  def execute_pre(interpreter, trace)
    io = interpreter.console_io
    s = 'IF ' + @expression.to_s
    io.trace_output(s) if trace
    values = @expression.evaluate(interpreter)
    raise(BASICException, 'Expression error') unless
      values.size == 1

    result = values[0]
    raise(BASICException, 'Expression error') unless
      result.class.to_s == 'BooleanConstant'

    s = ' ' + result.to_s
    io.trace_output(s) if trace
    return if result.value

    current_line_index = interpreter.current_line_index
    number = current_line_index.number
    statement_index = current_line_index.statement
    index = current_line_index.index
    fail_index = -index
    destination = LineNumberIndex.new(number, statement_index, fail_index)
    interpreter.next_line_index = destination
  end

  def execute_post(_, _) end

  private

  def parse_expression(expression_tokens)
    expression = nil
    begin
      expression = ValueScalarExpression.new(expression_tokens)
    rescue BASICException => e
      @errors << e.message
    end
    expression
  end
end

# FOR
class ForModifier
  attr_reader :errors

  def initialize(control_and_start_tokens, end_tokens, step_tokens)
    @errors = []
    parts = split_on_token(control_and_start_tokens, '=')

    raise(BASICException, 'Incorrect initialization') if
      parts.size != 3
    raise(BASICException, 'Incorrect initialization') if
      parts[1].to_s != '='

    control_tokens = parts[0]
    start_tokens = parts[2]

    @errors << 'Control variable must be a variable' unless
      control_tokens.class.to_s == 'Array' &&
      control_tokens.size > 0 &&
      control_tokens[0].variable?

    @control = VariableName.new(control_tokens[0])
    @start = ValueScalarExpression.new(start_tokens)
    @end = ValueScalarExpression.new(end_tokens)
    step_tokens = [NumericConstantToken.new(1)] if step_tokens.nil?
    @step_value = ValueScalarExpression.new(step_tokens)
  end

  def to_s
    "FOR #{@control} = #{@start} TO #{@end}"
  end

  def execute_pre(interpreter, trace)
    start = @start.evaluate(interpreter)[0]
    @current_value = start if @current_value.nil?
    interpreter.set_value(@control, @current_value, trace)
    end_value = @end.evaluate(interpreter)[0]
    step_value = @step_value.evaluate(interpreter)[0]

    terminated = terminated?(@current_value, step_value, end_value)

    io = interpreter.console_io
    print_trace_info(io, terminated) if
      trace

    return unless terminated

    current_line_index = interpreter.current_line_index
    number = current_line_index.number
    statement_index = current_line_index.statement
    index = current_line_index.index
    for_index = -index
    destination = LineNumberIndex.new(number, statement_index, for_index)
    interpreter.next_line_index = destination
  end

  def execute_post(interpreter, trace)
    end_value = @end.evaluate(interpreter)[0]
    step_value = @step_value.evaluate(interpreter)[0]
    @current_value += step_value
    interpreter.set_value(@control, @current_value, trace)

    if terminated?(@current_value, step_value, end_value) 
      @current_value = nil
    else
      current_line_index = interpreter.current_line_index
      number = current_line_index.number
      statement_index = current_line_index.statement
      index = current_line_index.index
      for_index = -index
      destination = LineNumberIndex.new(number, statement_index, for_index)
      interpreter.next_line_index = destination
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

  def terminated?(current_value, step_value, end_value)
    zero = NumericConstant.new(0)

    if step_value > zero
      current_value > end_value
    elsif step_value < zero
      current_value < end_value
    else
      false
    end
  end

  def print_trace_info(io, terminated)
    io.trace_output("FOR  #{@control} = #{@start} TO #{@end}")
    io.trace_output(" #{@control} = #{@current_value}  terminated:#{terminated}")
  end
end
