# token class
class AbstractElement
  def self.make_coord(c)
    [NumericConstant.new(c)]
  end

  def self.make_coords(r, c)
    [NumericConstant.new(r), NumericConstant.new(c)]
  end

  attr_reader :precedence

  def initialize
    @empty = false
    @operator = false
    @function = false
    @user_function = false
    @variable = false
    @operand = false
    @terminal = false
    @group_start = false
    @group_end = false
    @param_start = false
    @separator = false
    @file_handle = false
    @precedence = 10
    @shape = nil
    @list = false
    @carriage = false
    @valref = nil
    @numeric_constant = false
    @text_constant = false
    @boolean_constant = false
  end

  def dump
    "#{self.class}:Unimplemented"
  end

  def empty?
    @empty
  end

  def keyword?
    false
  end

  def operator?
    @operator
  end

  def function?
    @function
  end

  def user_function?
    @user_function
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

  def previous_is_array(stack)
    !stack.empty? && stack[-1].class.to_s == 'Array'
  end

  def file_handle?
    @file_handle
  end

  def scalar?
    @shape == :scalar
  end

  def array?
    @shape == :array
  end

  def matrix?
    @shape == :matrix
  end

  def list?
    @list
  end

  def carriage_control?
    @carriage
  end

  def value?
    @valref == :value
  end

  def reference?
    @valref == :reference
  end

  def numeric_constant?
    @numeric_constant
  end

  def text_constant?
    @text_constant
  end

  def boolean_constant?
    @boolean_constant
  end

  def pop_stack(stack); end

  private
  
  def make_sigils(types)
    sigil_chars = {
      numeric: '_',
      integer: '%',
      string: '$',
      boolean: '?'
    }

    sigils = []

    types.each do |type|
      sigils << sigil_chars[type]
    end

    sigils
  end

  def make_signature(types)
    sigils = make_sigils(types)

    '(' + sigils.join(',') + ')'
  end
end

# empty token
class EmptyToken < AbstractElement
  def initialize
    super

    @text = ''
    @empty = true
  end
end

# beginning of a group
class GroupStart < AbstractElement
  def self.accept?(token)
    classes = %w[GroupStartToken]
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
    classes = %w[GroupEndToken]
    classes.include?(token.class.to_s)
  end

  def initialize(element)
    super()

    @text = element.to_s
    @group_end = true
    @operand = true
  end

  def match?(start_element)
    (start_element.text == '(' && @text == ')') ||
      (start_element.text == '[' && @text == ']')
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
    classes = %w[ParamSeparatorToken]
    classes.include?(token.class.to_s)
  end

  def initialize(token)
    super()

    @text = token.to_s
    @separator = true
  end

  def to_s
    @text
  end
end

public

# class that holds a value
class AbstractValueElement < AbstractElement
  attr_reader :symbol

  def initialize
    super

    @shape = :scalar
    @value = nil
    @symbol = false
  end

  def dump
    "#{self.class}:#{to_s}"
  end

  def eql?(other)
    @value == other.to_v
  end

  def hash
    @value.hash
  end

  def <=>(other)
    return -1 if self < other
    return 1 if self > other
    0
  end

  def ==(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in =="
    raise(BASICExpressionError, message) unless compatible?(other)
    @value == other.to_v
  end

  def >(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in >"
    raise(BASICExpressionError, message) unless compatible?(other)
    @value > other.to_v
  end

  def >=(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in >="
    raise(BASICExpressionError, message) unless compatible?(other)
    @value >= other.to_v
  end

  def <(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in <"
    raise(BASICExpressionError, message) unless compatible?(other)
    @value < other.to_v
  end

  def <=(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in <="
    raise(BASICExpressionError, message) unless compatible?(other)
    @value <= other.to_v
  end

  def b_eq(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in b_eq()"
    raise(BASICExpressionError, message) unless compatible?(other)
    BooleanConstant.new(@value == other.to_v)
  end

  def b_ne(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in b_ne()"
    raise(BASICExpressionError, message) unless compatible?(other)
    BooleanConstant.new(@value != other.to_v)
  end

  def b_gt(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in b_gt()"
    raise(BASICExpressionError, message) unless compatible?(other)
    BooleanConstant.new(@value > other.to_v)
  end

  def b_ge(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in b_ge()"
    raise(BASICExpressionError, message) unless compatible?(other)
    BooleanConstant.new(@value >= other.to_v)
  end

  def b_lt(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in b_lt()"
    raise(BASICExpressionError, message) unless compatible?(other)
    BooleanConstant.new(@value < other.to_v)
  end

  def b_le(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in b_le()"
    raise(BASICExpressionError, message) unless compatible?(other)
    BooleanConstant.new(@value <= other.to_v)
  end

  def b_and(_)
    raise(BASICExpressionError, 'Invalid operator AND')
  end

  def b_or(_)
    raise(BASICExpressionError, 'Invalid operator OR')
  end

  def +(_)
    raise(BASICExpressionError, 'Invalid operator +')
  end

  def -(_)
    raise(BASICExpressionError, 'Invalid operator -')
  end

  def add(_)
    raise(BASICExpressionError, 'Invalid operator add')
  end

  def subtract(_)
    raise(BASICExpressionError, 'Invalid operator subtract')
  end

  def multiply(_)
    raise(BASICExpressionError, 'Invalid operator multiply')
  end

  def divide(_)
    raise(BASICExpressionError, 'Invalid operator divide')
  end

  def power(_)
    raise(BASICExpressionError, 'Invalid operator power')
  end

  def max(_)
    raise(BASICExpressionError, 'Invalid operator MAX')
  end

  def min(_)
    raise(BASICExpressionError, 'Invalid operator MIN')
  end

  def printable?
    true
  end

  def keyword?
    false
  end
  
  def evaluate(_, _)
    self
  end

  def to_v
    @value
  end

  def to_numeric
    @value
  end

  def compatible?(other)
    other.content_type == content_type
  end
end

# Numeric constants
class NumericConstant < AbstractValueElement
  def self.accept?(token)
    classes =
      %w[Fixnum Integer Bignum Float NumericConstantToken NumericSymbolToken]

    classes.include?(token.class.to_s)
  end

  def self.numeric(text)
    # #c constant
    if text.size == 2 && text[0] == '#'
      text[1].ord
    # nnn(E+nn)
    elsif /\A\s*[+-]?\d+(E+?\d+)?\z/ =~ text
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
    return f if f == Float::INFINITY

    i = f.to_i
    frac = f - i
    frac.zero? || (!i.zero? && frac.abs < 1e-7) ? i : f
  end

  public

  attr_reader :symbol_text

  def initialize(text)
    super()

    numeric_classes = %w[Fixnum Integer Bignum Float]
    float_classes = %w[Rational NumericConstantToken]
    f = nil
    f = text.to_f if float_classes.include?(text.class.to_s)
    f = text if numeric_classes.include?(text.class.to_s)

    if text.class.to_s == 'NumericConstantToken'
      t = text.to_s
      f = t[1].ord if !t.empty? && t[0] == '#'
    end

    if text.class.to_s == 'NumericSymbolToken'
      f = text.value
      @symbol = true
    end

    raise(BASICSyntaxError, "'#{text}' is not a number") if f.nil?

    precision = $options['precision'].value
    if precision != 'INFINITE' && f != 0 && f != Float::INFINITY
      abs_value = f.abs
      log_value = Math.log10(abs_value)
      ceil_value = log_value.ceil
      num_digits = -(ceil_value - precision)
      f = f.round(num_digits)
    end

    @symbol_text = text.to_s
    @value = float_to_possible_int(f)
    @operand = true
    @precedence = 0
    @numeric_constant = true
  end

  def dump
    self.class.to_s + ':' + @symbol_text
  end

  def zero?
    @value.zero?
  end

  def content_type
    :numeric
  end

  def set_content_type(type_stack)
    type_stack.push(content_type)
  end

  def shape
    :scalar
  end

  def set_shape(shape_stack)
    shape_stack.push(:scalar)
  end

  def eql?(other)
    @value == other.to_v
  end

  def ==(other)
    @value == other.to_v
  end

  def hash
    @value.hash + @symbol_text.hash
  end

  def <=>(other)
    @value <=> other.to_v
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

  def b_and(other)
    BooleanConstant.new(to_b && other.to_b)
  end

  def b_or(other)
    BooleanConstant.new(to_b || other.to_b)
  end

  def +(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in +()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value + other.to_numeric.to_v
    NumericConstant.new(value)
  end

  def -(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in -()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value - other.to_numeric.to_v
    NumericConstant.new(value)
  end

  def *(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in *()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value * other.to_numeric.to_v
    NumericConstant.new(value)
  end

  def add(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in add()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value + other.to_numeric.to_v
    NumericConstant.new(value)
  end

  def subtract(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in subtract()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value - other.to_numeric.to_v
    NumericConstant.new(value)
  end

  def multiply(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in multiply()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value * other.to_numeric.to_v
    NumericConstant.new(value)
  end

  def divide(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in divide()"

    raise(BASICExpressionError, message) unless compatible?(other)
    raise BASICRuntimeError.new(:te_div_zero) if other.zero?

    value = @value.to_f / other.to_numeric.to_f
    NumericConstant.new(value)
  end

  def power(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in power()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value**other.to_numeric.to_v
    NumericConstant.new(value)
  end

  def maximum(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in maximum()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = [@value, other.to_v].max
    NumericConstant.new(value)
  end

  def minimum(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in minimum()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = [@value, other.to_v].min
    NumericConstant.new(value)
  end

  def negate
    NumericConstant.new(-@value)
  end

  def truncate
    value = @value.to_i
    NumericConstant.new(value)
  end

  def floor
    value = @value.floor
    NumericConstant.new(value)
  end

  def to_int
    IntegerConstant.new(to_i)
  end

  def exp
    value = Math.exp(@value)
    NumericConstant.new(value)
  end

  def log
    value = @value > 0 ? Math.log(@value) : 0
    NumericConstant.new(value)
  end

  def log10
    value = @value > 0 ? Math.log10(@value) : 0
    NumericConstant.new(value)
  end

  def log2
    value = @value > 0 ? Math.log2(@value) : 0
    NumericConstant.new(value)
  end

  def mod(other)
    value = other.to_v != 0 ? @value % other.to_v : 0
    NumericConstant.new(value)
  end

  def abs
    value = @value >= 0 ? @value : -@value
    NumericConstant.new(value)
  end

  def round(places)
    NumericConstant.new(@value.round(places.to_i))
  end

  def sqrt
    value = @value > 0 ? Math.sqrt(@value) : 0
    NumericConstant.new(value)
  end

  def sin
    value = Math.sin(@value)
    NumericConstant.new(value)
  end

  def arcsin
    return 0 if @value < -1.0 || @value > 1.0
    NumericConstant.new(Math.asin(@value))
  end

  def cos
    value = Math.cos(@value)
    NumericConstant.new(value)
  end

  def arccos
    return 0 if @value < -1.0 || @value > 1.0
    NumericConstant.new(Math.acos(@value))
  end

  def tan
    value = @value >= 0 ? Math.tan(@value) : 0
    NumericConstant.new(value)
  end

  def cot
    cos = Math.cos(@value)
    sin = Math.sin(@value)
    cot = Float::INFINITY
    cot = cos / sin if sin.nonzero?
    NumericConstant.new(cot)
  end

  def atn
    value = Math.atan(@value)
    NumericConstant.new(value)
  end

  def atn2(a2)
    value = Math.atan2(@value, a2.to_f)
    NumericConstant.new(value)
  end

  def sec
    cos = Math.cos(@value)
    sec = Float::INFINITY
    sec = 1 / cos if cos.nonzero?
    NumericConstant.new(sec)
  end

  def csc
    sin = Math.sin(@value)
    csc = Float::INFINITY
    csc = 1 / sin if sin.nonzero?
    NumericConstant.new(csc)
  end

  def max(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in max()"
    raise(BASICExpressionError, message) unless compatible?(other)
    @value = [to_v, other.to_v].max
  end

  def min(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in min()"
    raise(BASICExpressionError, message) unless compatible?(other)
    @value = [to_v, other.to_v].min
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

  def to_s
    if @symbol
      @symbol_text
    else
      @value.to_s
    end
  end

  def to_b
    !@value.to_f.zero?
  end

  def to_numeric
    NumericConstant.new(@value)
  end

  def print(printer)
    s = to_formatted_s
    s = s.upcase
    printer.print_item s
    printer.last_was_numeric
  end

  def write(printer)
    s = to_formatted_s
    s = s.upcase
    printer.print_item s
  end

  def compatible?(other)
    other.numeric_constant?
  end

  private

  def to_formatted_s
    lead_space = @value >= 0 ? ' ' : ''
    digits = @value.to_s
    lead_space + digits
  end
end

# Integer constants
class IntegerConstant < AbstractValueElement
  def self.accept?(token)
    classes = %w[Fixnum Integer Bignum Float IntegerConstantToken]
    classes.include?(token.class.to_s)
  end

  def self.numeric(text)
    # nnn%
    text.to_f.to_i if /\A\s*[+-]?\d+%\z/ =~ text
  end

  attr_reader :symbol_text

  def initialize(text)
    super()

    numeric_classes = %w[Fixnum Integer Bignum Float NumericConstantToken]
    f = nil
    f = text.to_i if numeric_classes.include?(text.class.to_s)
    f = text.to_f.to_i if text.class.to_s == 'IntegerConstantToken'

    raise BASICSyntaxError, "'#{text}' is not a number" if f.nil?

    @symbol_text = text.to_s
    @value = f
    @operand = true
    @precedence = 0
    @numeric_constant = true
  end

  def zero?
    @value.zero?
  end

  def content_type
    :integer
  end

  def set_content_type(type_stack)
    type_stack.push(content_type)
  end

  def shape
    :scalar
  end

  def set_shape(shape_stack)
    shape_stack.push(:scalar)
  end

  def eql?(other)
    @value == other.to_v
  end

  def ==(other)
    @value == other.to_v
  end

  def hash
    @value.hash + @symbol_text.hash
  end

  def <=>(other)
    @value <=> other.to_v
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

  def b_and(other)
    if other.content_type == :integer && $options['int_bitwise'].value
      IntegerConstant.new(to_i & other.to_i)
    else
      BooleanConstant.new(to_b && other.to_b)
    end
  end

  def b_or(other)
    if other.content_type == :integer && $options['int_bitwise'].value
      IntegerConstant.new(to_i | other.to_i)
    else
      BooleanConstant.new(to_b || other.to_b)
    end
  end

  def +(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in +()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value + other.to_v
    IntegerConstant.new(value)
  end

  def -(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in -()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value - other.to_v
    IntegerConstant.new(value)
  end

  def *(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in *()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value * other.to_v
    IntegerConstant.new(value)
  end

  def add(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in add()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value + other.to_v
    IntegerConstant.new(value)
  end

  def subtract(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in subtract()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value - other.to_v
    IntegerConstant.new(value)
  end

  def multiply(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in multiply()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value * other.to_v
    IntegerConstant.new(value)
  end

  def divide(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in divide()"

    raise(BASICExpressionError, message) unless compatible?(other)
    raise BASICRuntimeError.new(:te_div_zero) if other.zero?

    value = @value.to_f / other.to_v.to_f
    IntegerConstant.new(value)
  end

  def power(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in power()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = @value**other.to_v
    IntegerConstant.new(value)
  end

  def maximum(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in maximum()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = [@value, other.to_v].max
    IntegerConstant.new(value)
  end

  def minimum(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in minimum()"

    raise(BASICExpressionError, message) unless compatible?(other)

    value = [@value, other.to_v].min
    IntegerConstant.new(value)
  end

  def negate
    IntegerConstant.new(-@value)
  end

  def truncate
    value = @value.to_i
    IntegerConstant.new(value)
  end

  def floor
    value = @value.floor
    IntegerConstant.new(value)
  end

  def exp
    value = Math.exp(@value)
    IntegerConstant.new(value)
  end

  def log
    value = @value > 0 ? Math.log(@value) : 0
    IntegerConstant.new(value)
  end

  def log10
    value = @value > 0 ? Math.log10(@value) : 0
    IntegerConstant.new(value)
  end

  def log2
    value = @value > 0 ? Math.log2(@value) : 0
    IntegerConstant.new(value)
  end

  def abs
    value = @value >= 0 ? @value : -@value
    IntegerConstant.new(value)
  end

  def sqrt
    value = @value > 0 ? Math.sqrt(@value) : 0
    IntegerConstant.new(value)
  end

  def sin
    value = Math.sin(@value)
    IntegerConstant.new(value)
  end

  def cos
    value = Math.cos(@value)
    IntegerConstant.new(value)
  end

  def tan
    value = @value >= 0 ? Math.tan(@value) : 0
    IntegerConstant.new(value)
  end

  def atn
    value = Math.atan(@value)
    IntegerConstant.new(value)
  end

  def max(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in max()"
    raise(BASICExpressionError, message) unless compatible?(other)
    @value = [to_v, other.to_v].max
  end

  def min(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in =="
    raise(BASICExpressionError, message) unless compatible?(other)
    @value = [to_v, other.to_v].min
  end

  def sign
    result = 0
    result = 1 if @value > 0
    result = -1 if @value < 0
    IntegerConstant.new(result)
  end

  def to_i
    @value.to_i
  end

  def to_f
    @value.to_i
  end

  def to_s
    @value.to_s
  end

  def to_b
    !@value.to_i.zero?
  end

  def to_numeric
    IntegerConstant.new(@value)
  end

  def print(printer)
    s = to_formatted_s
    s = s.upcase
    printer.print_item s
    printer.last_was_numeric
  end

  def write(printer)
    s = to_formatted_s
    s = s.upcase
    printer.print_item s
  end

  def compatible?(other)
    other.numeric_constant?
  end

  private

  def to_formatted_s
    lead_space = @value >= 0 ? ' ' : ''
    digits = @value.to_s
    lead_space + digits
  end
end

# Text constants
class TextConstant < AbstractValueElement
  def self.accept?(token)
    classes = %w[TextConstantToken TextSymbolToken]
    classes.include?(token.class.to_s)
  end

  attr_reader :value
  attr_reader :symbol_text

  def initialize(text)
    super()

    @value = nil
    @value = text.value if text.class.to_s == 'TextConstantToken'

    if text.class.to_s == 'TextSymbolToken'
      @value = text.value
      @symbol_text = text.text
      @symbol = true
    end

    raise(BASICExpressionError, "'#{text}' is not a text constant") if
      @value.nil?

    @operand = true
    @precedence = 0
    @text_constant = true
  end

  def content_type
    :string
  end

  def set_content_type(type_stack)
    type_stack.push(content_type)
  end

  def shape
    :scalar
  end

  def set_shape(shape_stack)
    shape_stack.push(:scalar)
  end

  def eql?(other)
    @value == other.to_v
  end

  def ==(other)
    @value == other.to_v
  end

  def hash
    @value.hash
  end

  def <=>(other)
    @value <=> other.to_v
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

  def b_and(other)
    BooleanConstant.new(to_b && other.to_b)
  end

  def b_or(other)
    BooleanConstant.new(to_b || other.to_b)
  end

  def +(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in +()"

    raise(BASICExpressionError, message) unless compatible?(other)

    unquoted = @value + other.to_v
    quoted = '"' + unquoted + '"'
    token = TextConstantToken.new(quoted)
    TextConstant.new(token)
  end

  def add(other)
    message = "Type mismatch (#{content_type}/#{other.content_type}) in add()"

    raise(BASICExpressionError, message) unless compatible?(other)

    unquoted = @value + other.to_v
    quoted = '"' + unquoted + '"'
    token = TextConstantToken.new(quoted)
    TextConstant.new(token)
  end

  def maximum(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in maximum()"

    raise(BASICExpressionError, message) unless compatible?(other)

    TextConstant.new([@value, other.to_v].max)
  end

  def minimum(other)
    message =
      "Type mismatch (#{content_type}/#{other.content_type}) in minimum()"

    raise(BASICExpressionError, message) unless compatible?(other)

    TextConstant.new([@value, other.to_v].min)
  end

  def to_s
    "\"#{@value}\""
  end

  def to_b
    !@value.size.zero?
  end

  def print(printer)
    printer.print_item @value
  end

  def write(printer)
    v = to_s
    printer.print_item v
  end

  def unpack
    length = NumericConstant.new(@value.size)
    dims = [length]
    values = {}
    values[[NumericConstant.new(0)]] = length
    index = 1
    @value.each_char do |char|
      key = [NumericConstant.new(index)]
      values[key] = NumericConstant.new(char.ord)
      index += 1
    end
    BASICArray.new(dims, values)
  end
end

# Boolean constants
class BooleanConstant < AbstractValueElement
  def self.accept?(token)
    classes = %w[BooleanConstantToken]
    classes.include?(token.class.to_s)
  end

  attr_reader :value
  attr_reader :symbol_text

  def initialize(obj)
    super()

    obj_class = obj.class.to_s
    @symbol_text = obj.to_s

    @value =
      (obj_class == 'BooleanConstantToken' && obj.to_s == 'TRUE') ||
      (obj_class == 'String' && obj.casecmp('TRUE').zero?) ||
      (obj_class == 'NumericConstant' && !obj.to_f.zero?) ||
      (obj_class == 'IntegerConstant' && !obj.to_i.zero?) ||
      (obj_class == 'TextConstant' && !obj.value.strip.size.zero?) ||
      obj_class == 'TrueClass'

    @operand = true
    @precedence = 0
    @boolean_constant = true
  end

  def content_type
    :boolean
  end

  def set_content_type(stack)
    stack.push(content_type)
  end

  def shape
    :scalar
  end

  def set_shape(shape_stack)
    shape_stack.push(:scalar)
  end

  def eql?(other)
    @value == other.to_v
  end

  def ==(other)
    @value == other.to_v
  end

  def hash
    @value.hash
  end

  def <=>(other)
    to_i <=> other.to_i
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

  def b_and(other)
    BooleanConstant.new(@value && other.to_b)
  end

  def b_or(other)
    BooleanConstant.new(@value || other.to_b)
  end

  def to_i
    @value ? 1 : 0
  end

  def to_s
    @value ? 'true' : 'false'
  end

  def to_formatted_s
    @value ? 'true' : 'false'
  end

  def to_b
    @value
  end

  def to_numeric
    @value ? NumericConstant.new(-1) : NumericConstant.new(0)
  end

  def print(printer)
    s = to_formatted_s
    s = s.upcase
    printer.print_item s
    printer.last_was_numeric
  end

  def write(printer)
    s = to_formatted_s
    s = s.upcase
    printer.print_item s
  end

  def compatible?(other)
    other.numeric_constant? || other.boolean_constant?
  end

  private

  def numeric_value
    @value ? -1 : 0
  end
end

# File handle class
class FileHandle < AbstractElement
  attr_reader :number

  def initialize(num)
    super()

    legals = %w[Fixnum Integer NumericConstant IntegerConstant FileHandle]

    raise BASICRuntimeError.new(:te_fh_inv) unless
      legals.include?(num.class.to_s)

    raise BASICRuntimeError.new(:te_fnum_inv) if num.to_i < 0

    @number = num.to_i
    @file_handle = true
  end

  def hash
    @number.hash
  end

  def eql?(other)
    @number == other.number
  end

  def to_s
    '#' + @number.to_s
  end

  def to_i
    @number
  end
end

# Carriage control for PRINT and MAT PRINT statements
class CarriageControl
  def self.accept?(token)
    classes = %w[ParamSeparatorToken]
    classes.include?(token.class.to_s)
  end

  attr_reader :comprehension_effort

  def initialize(token)
    token = ',' if token == 'COMMA'
    token = ';' if token == 'SEMI'
    token = '' if token == 'NONE'

    @operator = token.to_s
    @carriage = true
    @file_handle = false
    @comprehension_effort = 0
  end

  def printable?
    false
  end

  def keyword?
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

  def dump
    ["#{self.class}:#{@operator}"]
  end

  def carriage_control?
    @carriage
  end

  def filehandle?
    @file_handle
  end

  def numerics
    []
  end

  def num_symbols
    []
  end

  def strings
    []
  end

  def booleans
    []
  end

  def text_symbols
    []
  end

  def variables
    []
  end

  def operators
    []
  end

  def functions
    []
  end

  def userfuncs
    []
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

  def write(printer, _)
    case @operator
    when ','
      printer.print_item(@operator)
    when ';'
      printer.print_item(@operator)
    when 'NL'
      printer.newline
    when ''
      printer.print_item(',')
    end
  end
end

# Hold a variable name
class VariableName < AbstractElement
  def self.accept?(token)
    classes = %w[VariableToken]
    classes.include?(token.class.to_s)
  end

  attr_reader :name

  def initialize(token)
    super()

    raise(BASICSyntaxError, "'#{token}' is not a variable token") unless
      token.class.to_s == 'VariableToken'

    @name = token
    @variable = true
    @operand = true
    @precedence = 7
    @content_type = @name.content_type
  end

  def content_type
    @content_type
  end

  def set_content_type(stack)
    stack.push(content_type)
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

  def scalar?
    true
  end

  def dump
    "#{self.class}:#{@name}"
  end

  def compatible?(value)
    numerics = %i[numeric integer]
    strings = %i[string]

    case content_type
    when :numeric
      numerics.include?(value.content_type)
    when :string
      strings.include?(value.content_type)
    when :integer
      numerics.include?(value.content_type)
    else
      false
    end
  end

  def subscripts
    []
  end

  def to_s
    @name.to_s
  end
end

# Hold a function name
class UserFunctionName < AbstractElement
  def self.accept?(token)
    classes = %w[UserFunctionToken]
    classes.include?(token.class.to_s)
  end

  attr_reader :name
  attr_reader :content_type
  attr_reader :shape

  def initialize(token)
    super()

    raise(BASICSyntaxError, "'#{token}' is not a function name") unless
      token.class.to_s == 'UserFunctionToken'

    @name = token
    @function = true
    @user_function = true
    @operand = true
    @precedence = 7
    @content_type = @name.content_type
    @shape = :scalar
  end

  def set_content_type(type_stack)
    type_stack.push(content_type)
  end

  def set_shape(shape_stack)
    shape_stack.push(:scalar)
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

  def scalar?
    true
  end

  def default_shape
    :scalar
  end

  def dump
    "#{self.class}:#{@name}"
  end

  def compatible?(value)
    numerics = %i[numeric integer]
    strings = %i[string]

    compatible = false

    if content_type == :numeric
      compatible = numerics.include?(value.content_type)
    end

    if content_type == :string
      compatible = strings.include?(value.content_type)
    end

    if content_type == :integer
      compatible = numerics.include?(value.content_type)
    end

    compatible
  end

  def subscripts
    []
  end

  def to_s
    @name.to_s
  end
end

# Hold a variable (name with possible subscripts and value)
class Variable < AbstractElement
  attr_writer :valref
  attr_reader :shape
  attr_reader :subscripts

  def initialize(variable_name, my_shape, subscripts)
    super()

    raise(BASICExpressionError,
          "'#{variable_name.class}:#{variable_name}' is not a variable name") if
      variable_name.class.to_s != 'VariableName'

    @variable_name = variable_name
    @valref = :value
    @shape = my_shape
    @subscripts = normalize_subscripts(subscripts)
    @variable = true
    @operand = true
    @precedence = 7
  end

  def content_type
    @variable_name.content_type
  end

  def set_content_type(type_stack)
    unless type_stack.empty?
      types = type_stack[-1]

      if types.class.to_s == 'Array'
        type_stack.pop

        @sigils = make_sigils(types)
        @signature = make_signature(types)
      end
    end

    type_stack.push(content_type)
  end

  def set_shape(shape_stack)
    unless shape_stack.empty?
      shapes = shape_stack[-1]
      shape_stack.pop if shapes.class.to_s == 'Array'
    end

    @signature = '()' if @shape == :array
    @signature = '(,)' if @shape == :matrix

    shape_stack.push(@shape)
  end

  def eql?(other)
    @variable_name == other.name && @subscripts == other.subscripts
  end

  def ==(other)
    @variable_name == other.name && @subscripts == other.subscripts
  end

  def hash
    @variable_name.hash && @subscripts.hash
  end

  def dump
    "#{self.class}:#{@variable_name}#{@signature} #{content_type} #{@shape}"
  end

  def name
    @variable_name
  end

  def dimensions?
    !@subscripts.empty?
  end

  def dimensions
    @subscripts
  end

  def compatible?(value)
    numerics = %i[numeric integer]
    strings = %i[string]

    compatible = false

    if content_type == :numeric
      compatible = numerics.include?(value.content_type)
    end

    if content_type == :string
      compatible = strings.include?(value.content_type)
    end

    if content_type == :integer
      compatible = numerics.include?(value.content_type)
    end

    compatible
  end

  def to_s
    if subscripts.empty?
      @variable_name.to_s
    else
      @variable_name.to_s + '(' + @subscripts.join(',') + ')'
    end
  end

  def evaluate(interpreter, stack)
    x = false
    x = evaluate_value(interpreter, stack) if @valref == :value
    x = evaluate_ref(interpreter, stack) if @valref == :reference
    x
  end

  private

  def evaluate_value(interpreter, stack)
    x = nil
    x = evaluate_value_scalar(interpreter, stack) if @shape == :scalar
    x = evaluate_value_array(interpreter, stack) if @shape == :array
    x = evaluate_value_matrix(interpreter, stack) if @shape == :matrix
    x
  end

  def evaluate_ref(interpreter, stack)
    x = nil
    x = evaluate_ref_scalar(interpreter, stack) if @shape == :scalar

    x = evaluate_ref_compound(interpreter, stack) if
      @shape == :array || @shape == :matrix
    x
  end

  def normalize_subscripts(subscripts)
    raise(BASICSyntaxError, 'Invalid subscripts container') unless
      subscripts.class.to_s == 'Array'

    int_subscripts = []
    subscripts.each do |subscript|
      raise(BASICExpressionError, "Invalid subscript #{subscript}") unless
        subscript.numeric_constant?

      int_subscripts << subscript.truncate
    end

    int_subscripts
  end

  # return a single value
  def evaluate_value_scalar(interpreter, stack)
    if previous_is_array(stack)
      subscripts = get_subscripts(stack)
      @subscripts = interpreter.normalize_subscripts(subscripts)
      interpreter.check_subscripts(@variable_name, @subscripts)
    end
    interpreter.get_value(self)
  end

  def get_subscripts(stack)
    subscripts = stack.pop

    if subscripts.empty?
      raise(BASICExpressionError,
            'Variable expects subscripts, found empty parentheses')
    end

    subscripts
  end

  def evaluate_value_array(interpreter, _)
    dims = interpreter.get_dimensions(@variable_name)
    raise(BASICExpressionError, 'Variable has no dimensions') if dims.nil?
    raise(BASICExpressionError, 'Array requires one dimension') if
      dims.size != 1
    values = evaluate_value_array_1(interpreter, dims[0].to_i)
    BASICArray.new(dims, values)
  end

  def evaluate_value_array_1(interpreter, n_cols)
    values = {}

    base = $options['base'].value
    (base..n_cols).each do |col|
      coords = AbstractElement.make_coord(col)
      variable = Variable.new(@variable_name, :array, coords)
      values[coords] = interpreter.get_value(variable)
    end

    values
  end

  def evaluate_value_matrix(interpreter, _)
    dims = interpreter.get_dimensions(@variable_name)
    raise(BASICExpressionError, 'Variable has no dimensions') if dims.nil?
    values = evaluate_matrix_n(interpreter, dims)
    Matrix.new(dims, values)
  end

  def evaluate_matrix_n(interpreter, dims)
    values = {}

    values = evaluate_value_matrix_1(interpreter, dims[0].to_i) if
      dims.size == 1

    values = evaluate_value_matrix_2(interpreter, dims[0].to_i, dims[1].to_i) if
      dims.size == 2

    values
  end

  def evaluate_value_matrix_1(interpreter, n_cols)
    values = {}

    base = $options['base'].value

    (base..n_cols).each do |col|
      coords = AbstractElement.make_coord(col)
      variable = Variable.new(@variable_name, :matrix, coords)
      values[coords] = interpreter.get_value(variable)
    end

    values
  end

  def evaluate_value_matrix_2(interpreter, n_rows, n_cols)
    values = {}

    base = $options['base'].value

    (base..n_rows).each do |row|
      (base..n_cols).each do |col|
        coords = AbstractElement.make_coords(row, col)
        variable = Variable.new(@variable_name, :matrix, coords)
        values[coords] = interpreter.get_value(variable)
      end
    end

    values
  end

  # return a single value, a reference to this object
  def evaluate_ref_scalar(interpreter, stack)
    if previous_is_array(stack)
      subscripts = stack.pop
      @subscripts = interpreter.normalize_subscripts(subscripts)
      num_args = @subscripts.length

      if num_args.zero?
        raise(BASICExpressionError,
              'Variable expects subscripts, found empty parentheses')
      end

      interpreter.check_subscripts(@variable_name, @subscripts)
    end
    self
  end

  # return a single value, a reference to this object
  def evaluate_ref_compound(interpreter, stack)
    if previous_is_array(stack)
      subscripts = stack.pop
      @subscripts = interpreter.normalize_subscripts(subscripts)
      num_args = @subscripts.length

      if num_args.zero?
        raise(BASICExpressionError,
              'Variable expects subscripts, found empty parentheses')
      end

      interpreter.check_subscripts(@variable_name, @subscripts)
    end

    self
  end
end

class Declaration < AbstractElement
  attr_reader :subscripts
  attr_reader :shape

  def initialize(variable_name)
    super()

    raise(BASICSyntaxError,
          "'#{variable_name}' is not a variable name") if
      variable_name.class.to_s != 'VariableName'

    @variable_name = variable_name
    @subscripts = []
    @variable = true
    @shape = :unknown
  end

  def dump
    "#{self.class}:#{@variable_name} #{@shape}"
  end

  def name
    @variable_name
  end

  def content_type
    @variable_name.content_type
  end

  def set_content_type(type_stack)
    type_stack.push(content_type)
  end

  def set_shape(shape_stack)
    @shape = :scalar
    @shape = :array if @subscripts.size == 1
    @shape = :matrix if @subscripts.size == 2

    shape_stack.push(@shape)
  end

  def to_s
    if subscripts.empty?
      @variable_name.to_s
    else
      @variable_name.to_s + '(' + @subscripts.join(',') + ')'
    end
  end

  # return a single value, a reference to this object
  def evaluate(_, stack)
    if previous_is_array(stack)
      @subscripts = stack.pop
      num_args = @subscripts.length

      if num_args.zero?
        raise(BASICExpressionError,
              'Variable expects subscripts, found empty parentheses')
      end
    end

    self
  end
end

# A list (needed because it has precedence value)
class ExpressionList < AbstractElement
  attr_reader :expressions

  def initialize(expressions)
    super()

    @list = true
    @expressions = expressions
    @variable = true
    @precedence = 7
  end

  def dump
    lines = []

    @expressions.each { |expression| lines.concat expression.dump }

    lines
  end

  def content_type
    types = []

    @expressions.each { |expression| types << expression.content_type }

    types
  end

  def set_content_type(type_stack)
    @expressions.each { |expression| expression.set_content_type }
    
    type_stack.push(content_type)
  end

  def shape
    shapes = []

    @expressions.each { |expression| shapes << expression.shape }

    shapes
  end

  def set_shape(shape_stack)
    @expressions.each { |expression| expression.set_shape }

    shape_stack.push(shape)
  end

  def evaluate(interpreter, _)
    interpreter.evaluate(@expressions)
  end

  def to_s
    "[#{@expressions.join('] [')}]"
  end

  def size
    @expressions.size
  end

  def count
    @expressions.count
  end
end

# class to hold REM text
class Remark < AbstractElement
  def initialize(tokens)
    super()

    @texts = []
    @texts = tokens.map(&:to_s) unless tokens.nil?
  end

  def dump
    "#{self.class}:#{@texts.join}"
  end
end
