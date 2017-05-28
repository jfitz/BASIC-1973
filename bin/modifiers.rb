# IF
class IfModifier
  def initialize(tokens_lists)
    @expression = parse_expression(tokens_lists[0])
  end

  def execute(interpreter)
    values = @expression.evaluate(interpreter)
    raise(BASICException, 'Expression error') unless
      values.size == 1
    result = values[0]
    raise(BASICException, 'Expression error') unless
      result.class.to_s == 'BooleanConstant'
    unless result.value
      current_line_index = interpreter.current_line_index
      number = current_line_index.number
      statement_index = current_line_index.statement
      index = current_line_index.index
      fail_index = -index
      destination = LineNumberIndex.new(number, statement_index, fail_index)
      interpreter.next_line_index = destination
    end
  end

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

# IF END
class IfEndModifier
  def initialize
  end

  def execute(_, _)
  end
end
