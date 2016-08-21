# token class
class AbstractElement
  attr_reader :precedence

  def initialize
    @operator = false
    @function = false
    @variable = false
    @operand = false
    @terminal = false
    @group_start = false
    @group_end = false
    @param_start = false
    @separator = false
    @precedence = 10
  end

  def operator?
    @operator
  end

  def function?
    @function
  end

  def variable?
    @variable
  end

  def function_variable?
    function? || variable?
  end

  def operand?
    @operand
  end

  def terminal?
    @terminal
  end

  def group_start?
    @group_start
  end

  def group_end?
    @group_end
  end

  def param_start?
    @param_start
  end

  def starter?
    @group_start || @param_start
  end

  def separator?
    @separator
  end

  def group_separator?
    group_start? || group_end? || separator?
  end

  protected

  def make_coord(c)
    [NumericConstant.new(c)]
  end

  def make_coords(r, c)
    [NumericConstant.new(r), NumericConstant.new(c)]
  end
end

# beginning of a group
class GroupStart < AbstractElement
  def self.accept?(token)
    classes = %w(GroupStartToken)
    classes.include?(token.class.to_s)
  end

  attr_reader :text

  def initialize(element)
    super()
    @text = element.to_s
    @group_start = true
  end

  def to_s
    @text
  end
end

# end of a group
class GroupEnd < AbstractElement
  def self.accept?(token)
    classes = %w(GroupEndToken)
    classes.include?(token.class.to_s)
  end

  def initialize(element)
    super()
    @text = element.to_s
    @group_end = true
    @operand = true
  end

  def compatible?(start_element)
    if start_element.class.to_s == 'GroupStart'
      return true if @text == ')' && start_element.text == '('
      return true if @text == ']' && start_element.text == '['
    end

    if start_element.class.to_s == 'ParamStart'
      return true if @text == ')' && start_element.text == '('
      return true if @text == ']' && start_element.text == '['
    end

    false
  end

  def to_s
    @text
  end
end

# beginning of a set of parameters
class ParamStart < AbstractElement

  attr_reader :text

  def initialize(element)
    super()
    @text = element.to_s
    @param_start = true
  end

  def to_s
    @text
  end
end

# separator for group or params
class ParamSeparator < AbstractElement
  def self.accept?(token)
    classes = %w(ParamSeparatorToken)
    classes.include?(token.class.to_s)
  end

  def initialize(text)
    super()
    @text = text
    @separator = true
  end

  def to_s
    @text
  end
end

public

# Numeric constants
class NumericConstant < AbstractElement
  def self.accept?(token)
    classes = %w(Fixnum Bignum Float NumericConstantToken)
    classes.include?(token.class.to_s)
  end

  def self.init?(text)
    numeric_classes = %w(Fixnum Bignum Float)
    numeric_classes.include?(text.class.to_s) || !numeric(text).nil?
  end

  def self.numeric(text)
    # nnn(E+nn)
    if /\A\s*[+-]?\d+(E+?\d+)?\z/ =~ text
      text.to_f.to_i
    # nnn(E-nn)
    elsif /\A\s*[+-]?\d+(E-\d+)?\z/ =~ text
      text.to_f
    # nnn.(nnn)(E+-nn)
    elsif /\A\s*[+-]?\d+\.(\d*)?(E[+-]?\d+)?\z/ =~ text
      text.to_f
    # (nnn).nnn(E+-nn)
    elsif /\A\s*[+-]?(\d+)?\.\d*(E[+-]?\d+)?\z/ =~ text
      text.to_f
    end
  end

  private

  def float_to_possible_int(f)
    i = f.to_i
    (f - i).abs < 1e-8 ? i : f
  end

  public

  def initialize(text)
    super()
    numeric_classes = %w(Fixnum Bignum Float)
    f = text if numeric_classes.include?(text.class.to_s)
    f = text.to_f if text.class.to_s == 'NumericConstantToken'
    @value = float_to_possible_int(f)
    @operand = true
    @precedence = 0
    raise BASICException, "'#{text}' is not a number" if @value.nil?
  end

  def eql?(other)
    @value == other.to_v
  end

  def hash
    @value.hash
  end

  def ==(other)
    @value == other.to_v
  end

  def >(other)
    @value > other.to_v
  end

  def >=(other)
    @value >= other.to_v
  end

  def <(other)
    @value < other.to_v
  end

  def <=(other)
    @value <= other.to_v
  end

  def b_eq(other)
    BooleanConstant.new(@value == other.to_v)
  end

  def b_ne(other)
    BooleanConstant.new(@value != other.to_v)
  end

  def b_gt(other)
    BooleanConstant.new(@value > other.to_v)
  end

  def b_ge(other)
    BooleanConstant.new(@value >= other.to_v)
  end

  def b_lt(other)
    BooleanConstant.new(@value < other.to_v)
  end

  def b_le(other)
    BooleanConstant.new(@value <= other.to_v)
  end

  def +(other)
    NumericConstant.new(@value + other.to_v)
  end

  def -(other)
    NumericConstant.new(@value - other.to_v)
  end

  def *(other)
    NumericConstant.new(@value * other.to_v)
  end

  def add(other)
    NumericConstant.new(@value + other.to_v)
  end

  def subtract(other)
    NumericConstant.new(@value - other.to_v)
  end

  def multiply(other)
    NumericConstant.new(@value * other.to_v)
  end

  def divide(other)
    raise(BASICException, 'Divide by zero') if other == NumericConstant.new(0)
    NumericConstant.new(@value.to_f / other.to_v.to_f)
  end
 
  def power(other)
    NumericConstant.new(@value**other.to_v)
  end

  def matrix?
    false
  end

  def evaluate(_, _)
    self
  end

  def truncate
    NumericConstant.new(@value.to_i)
  end

  def floor
    NumericConstant.new(@value.floor)
  end

  def exp
    NumericConstant.new(Math.exp(@value))
  end

  def log
    NumericConstant.new(@value > 0 ? Math.log(@value) : 0)
  end

  def abs
    NumericConstant.new(@value >= 0 ? @value : -@value)
  end

  def sqrt
    NumericConstant.new(@value > 0 ? Math.sqrt(@value) : 0)
  end

  def sin
    NumericConstant.new(Math.sin(@value))
  end

  def cos
    NumericConstant.new(Math.cos(@value))
  end

  def tan
    NumericConstant.new(@value >= 0 ? Math.tan(@value) : 0)
  end

  def atn
    NumericConstant.new(Math.atan(@value))
  end

  def sign
    result = 0
    result = 1 if @value > 0
    result = -1 if @value < 0
    NumericConstant.new(result)
  end

  def to_i
    @value.to_i
  end

  def to_f
    @value.to_f
  end

  def to_v
    @value
  end

  def to_s
    @value.to_s
  end

  def six_digits(value)
    # ensure only 6 digits of precision
    decimals = 5 - (value != 0 ? Math.log(value.abs, 10).to_i : 0)
    rounded = value.round(decimals)
    rounded.to_f
  end

  def print(printer)
    s = to_formatted_s
    printer.print_item s
    printer.last_was_numeric
  end

  private

  def to_formatted_s
    lead_space = @value >= 0 ? ' ' : ''
    digits = six_digits(@value).to_s
    # remove trailing zeros and decimal point
    digits = digits.sub(/0+\z/, '').sub(/\.\z/, '') if
      digits.include?('.') && !digits.include?('e')
    lead_space + digits
  end
end

# Text constants
class TextConstant < AbstractElement
  def self.accept?(token)
    classes = %w(TextConstantToken)
    classes.include?(token.class.to_s)
  end

  def self.init?(text)
    /\A".*"\z/.match(text)
  end

  attr_reader :value

  def initialize(text)
    super()
    @value = nil
    @value = text.value if text.class.to_s == 'TextConstantToken'
    raise(BASICException, "'#{text}' is not a text constant") if @value.nil?
    @operand = true
    @precedence = 0
  end

  def evaluate(_, _)
    self
  end

  def matrix?
    false
  end

  def b_eq(other)
    BooleanConstant.new(@value == other.to_v)
  end

  def b_ne(other)
    BooleanConstant.new(@value != other.to_v)
  end

  def b_gt(other)
    BooleanConstant.new(@value > other.to_v)
  end

  def b_ge(other)
    BooleanConstant.new(@value >= other.to_v)
  end

  def b_lt(other)
    BooleanConstant.new(@value < other.to_v)
  end

  def b_le(other)
    BooleanConstant.new(@value <= other.to_v)
  end

  def printable?
    true
  end

  def to_v
    @value
  end

  def to_s
    "\"#{@value}\""
  end

  def print(printer)
    printer.print_item @value
  end
end

# Boolean constants
class BooleanConstant < AbstractElement
  attr_reader :value

  def initialize(text)
    super()
    @value = false
    @value = true if text.class.to_s == 'BooleanConstantToken' &&
                     text.boolean_constant == 'ON'
    @value = true if text.class.to_s == 'String' && text.to_s.casecmp('ON') == 0
    @value = true if text.class.to_s == 'TrueClass'
    @operand = true
    @precedence = 0
  end

  def to_s
    @value ? 'true' : 'false'
  end
end

# Carriage control for PRINT and MAT PRINT statements
class CarriageControl
  def self.accept?(token)
    classes = %w(ParamSeparatorToken)
    classes.include?(token.class.to_s)
  end

  def self.init?(text)
    text = text.to_s if text.class.to_s == 'ParamSeparatorToken'
    ['NL', ',', ';', ''].include?(text)
  end

  def initialize(text)
    raise(BASICException, "'#{text}' is not a valid separator") unless
      CarriageControl.init?(text)
    text = text.to_s if text.class.to_s == 'ParamSeparatorToken'
    @operator = text
  end

  def printable?
    false
  end

  def to_s
    case @operator
    when ';'
      '; '
    when ','
      ', '
    when 'NL'
      ''
    when ''
      ' '
    end
  end

  def print(printer, _)
    case @operator
    when ','
      printer.tab
    when ';'
      printer.semicolon
    when 'NL'
      printer.newline
    when ''
      printer.implied
    end
  end
end

# Hold a variable name (not a reference or value)
class VariableName < AbstractElement
  def self.accept?(token)
    classes = %w(VariableToken)
    classes.include?(token.class.to_s)
  end

  def self.init?(text)
    /\A[A-Z]\d?\$?\z/.match(text)
  end

  attr_reader :name
  attr_reader :content_type

  def initialize(token)
    super()
    raise(BASICException, "'#{token}' is not a variable name") unless
      token.class.to_s == 'VariableToken'
    @name = token
    @variable = true
    @operand = true
    @precedence = 7
    @content_type = @name.content_type
  end

  def eql?(other)
    to_s == other.to_s
  end

  def ==(other)
    to_s == other.to_s
  end

  def hash
    @name.hash
  end

  def to_s
    @name.to_s
  end
end

# Hold a variable (name with possible subscripts and value)
class Variable < AbstractElement
  attr_reader :subscripts

  def initialize(variable_name, subscripts = [])
    super()
    raise(BASICException, "'#{variable_name}' is not a variable name") if
      variable_name.class.to_s != 'VariableName'
    @variable_name = variable_name
    @subscripts = subscripts
    @variable = true
    @operand = true
    @precedence = 7
  end

  def name
    @variable_name
  end

  def content_type
    @variable_name.content_type
  end

  def to_s
    if subscripts.empty?
      @variable_name.to_s
    else
      @variable_name.to_s + '(' + @subscripts.join(',') + ')'
    end
  end
end

# A list (needed because it has precedence value)
class List < AbstractElement
  def initialize(parsed_expressions)
    super()
    @parsed_expressions = parsed_expressions
    @variable = true
    @precedence = 7
  end

  def list
    @parsed_expressions
  end

  def evaluate(interpreter, _)
    interpreter.evaluate(@parsed_expressions)
  end

  def to_s
    "[#{@parsed_expressions.join('] [')}]"
  end
end

# Scalar function (provides a scalar)
class Function < AbstractElement
  def initialize(text)
    super()
    @name = text
    @function = true
    @operand = true
    @precedence = 7
  end

  private

  def ensure_argument_count(stack, expected)
    raise(BASICException, @name + ' requires argument') if
      stack.empty? || stack[-1].class.to_s != 'Array'
    valid = counts_to_text(expected)
    raise(BASICException, @name + ' requires ' + valid + ' argument') unless
      expected.include? stack[-1].size
  end

  def counts_to_text(counts)
    words = %w( zero one two )
    texts = counts.map { |v| words[v] }
    texts.join(' or ')
  end

  def check_args(args)
    raise(BASICException, 'No arguments for function') if
      args.class.to_s != 'Array'
  end

  def check_value(value, type)
    raise(BASICException,
          "Argument #{x} #{x.class} not of type #{type.class}") if
      value.class.to_s != type
  end

  def check_arg_types(args, types)
    check_args(args)
    n_types = types.size
    n_args = args.size
    raise(BASICException,
          "Function #{@name} expects #{n_types} argument, found #{n_args}") if
      n_args != n_types
    (0..types.size - 1).each do |i|
      check_value(args[i], types[i])
    end
  end
end
