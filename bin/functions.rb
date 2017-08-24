# function (provides a result)
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
    raise(BASICException, @name + ' requires argument') unless
      previous_is_array(stack)
    valid = counts_to_text(expected)
    raise(BASICException, @name + ' requires ' + valid + ' argument') unless
      expected.include? stack[-1].size
  end

  def counts_to_text(counts)
    words = %w(zero one two)
    texts = counts.map { |v| words[v] }
    texts.join(' or ')
  end

  def check_args(args)
    raise(BASICException, 'No arguments for function') if
      args.class.to_s != 'Array'
  end

  def check_value(value, spec)
    compatible = false
    type = spec['type']
    shape = spec['shape']
    case type
    when 'numeric'
      compatible = value.numeric_constant?
    when 'text'
      compatible = value.text_constant?
    when 'boolean'
      compatible = value.boolean_constant?
    end

    raise(BASICException, "Type mismatch value #{value} not #{type}") unless
      compatible

    compatible = false
    case shape
    when 'scalar'
      compatible = value.scalar?
    when 'array'
      compatible = value.array?
    when 'matrix'
      compatible = value.matrix?
    end

    raise(BASICException, "Type mismatch value #{value} not #{shape}") unless
      compatible
  end

  def check_arg_types(args, specs)
    check_args(args)
    n_specs = specs.size
    n_args = args.size
    if n_args != n_specs
      raise(BASICException,
            "Function #{@name} expects #{n_specs} argument, found #{n_args}")
    end
    (0..n_specs - 1).each do |i|
      check_value(args[i], specs[i])
    end
  end
end

# Function that expects scalar parameters
class AbstractScalarFunction < Function
  def initialize(text)
    super
  end

  def default_type
    ScalarValue
  end
end

# User-defined function (provides a scalar value)
class UserFunction < AbstractScalarFunction
  def self.accept?(token)
    classes = %w(UserFunctionToken)
    classes.include?(token.class.to_s)
  end

  def self.init?(text)
    /\AFN[A-Z]\z/.match(text)
  end

  def initialize(text)
    text = text.to_s if text.class.to_s == 'UserFunctionToken'
    raise(BASICException, "'#{text}' is not a valid function") unless
      UserFunction.init?(text)
    super
  end

  # return a single value
  def evaluate(interpreter, stack, trace)
    expression = interpreter.get_user_function(@name)
    # verify function is defined
    raise(BASICException, "Function #{@name} not defined") if expression.nil?

    # verify arguments
    user_var_values = stack.pop
    raise(BASICException, 'No arguments for function') if
      user_var_values.class.to_s != 'Array'
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    specs = [spec] * user_var_values.length
    check_arg_types(user_var_values, specs)

    # dummy variable names and their (now known) values
    result =
      expression.evaluate_with_vars(interpreter, @name,
                                    user_var_values, trace)
    result[0]
  end
end

# Function that expects array parameters
class AbstractArrayFunction < Function
  def initialize(text)
    super
  end

  def default_type
    ArrayValue
  end
end

# Function that expects matrix parameters
class AbstractMatrixFunction < Function
  def initialize(text)
    super
  end

  def default_type
    MatrixValue
  end

  def check_square(dims)
    raise(BASICException, @name + ' requires matrix') unless dims.size == 2
    raise(BASICException, @name + ' requires square matrix') unless
      dims[1] == dims[0]
  end
end

# function ABS
class FunctionAbs < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    args[0].abs
  end
end

# function ASC
class FunctionAsc < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'text', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    text = args[0].to_v
    raise(BASICException, 'Empty string in ASC()') if text.empty?
    value = text[0].ord
    raise(BASICException, 'Invalid value in ASC()') unless
      value.between?(32, 126)
    token = NumericConstantToken.new(value.to_s)
    NumericConstant.new(token)
  end
end

# function ATN
class FunctionAtn < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    args[0].atn
  end
end

# function CHR$
class FunctionChr < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    value = args[0].to_i
    raise(BASICException, 'Invalid value for CHR$()') unless
      value.between?(32, 126)
    text = value.chr
    quoted = '"' + text + '"'
    token = TextConstantToken.new(quoted)
    TextConstant.new(token)
  end
end

# function CON
class FunctionCon < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1, 2])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec] * args.size)
    matrix = Matrix.new(args.clone, {})
    Matrix.new(matrix.dimensions, matrix.one_values)
  end
end

# function COS
class FunctionCos < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    args[0].cos
  end
end

# function DET
class FunctionDet < AbstractMatrixFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'matrix' }
    check_arg_types(args, [spec])
    args[0].determinant
  end
end

# function EXP
class FunctionExp < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    args[0].exp
  end
end

# function EXT$
class FunctionExt < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [3])
    args = stack.pop
    specs = [
      { 'type' => 'text', 'shape' => 'scalar' },
      { 'type' => 'numeric', 'shape' => 'scalar' },
      { 'type' => 'numeric', 'shape' => 'scalar' }
    ]
    check_arg_types(args, specs)
    value = args[0].to_v
    start = args[1].to_i
    stop = args[2].to_i
    raise(BASICException, 'Invalid index for EXT$()') if
      start < 1 || start > value.size || stop < start || stop > value.size
    text = value[(start - 1)..(stop - 1)]
    quoted = '"' + text + '"'
    token = TextConstantToken.new(quoted)
    TextConstant.new(token)
  end
end

# function IDN
class FunctionIdn < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1, 2])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec] * args.size)
    check_square(args) if args.size == 2
    dims = [args[0]] * 2
    matrix = Matrix.new(dims, {})
    Matrix.new(dims, matrix.identity_values)
  end

  private

  def check_square(dims)
    raise(BASICException, @name + ' requires matrix') unless dims.size == 2
    raise(BASICException, @name + ' requires square matrix') unless
      dims[1] == dims[0]
  end
end

# function INSTR
class FunctionInstr < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [3])
    args = stack.pop
    specs = [
      { 'type' => 'numeric', 'shape' => 'scalar' },
      { 'type' => 'text', 'shape' => 'scalar' },
      { 'type' => 'text', 'shape' => 'scalar' }
    ]
    check_arg_types(args, specs)
    start = args[0].to_i
    raise(BASICException, "Invalid start index for #{@name}()") if start < 1
    start -= 1
    value = args[1].to_v
    search = args[2].to_v
    index = value.index(search, start)
    if index.nil?
      index = 0
    else
      index += 1
    end
    token = IntegerConstantToken.new(index)
    IntegerConstant.new(token)
  end
end

# function INT
class FunctionInt < AbstractScalarFunction
  def initialize(text)
    super
  end

  # return a single value
  def evaluate(interpreter, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    interpreter.int_floor? ? args[0].floor : args[0].truncate
  end
end

# function INV
class FunctionInv < AbstractMatrixFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    dims = args[0].dimensions
    spec = { 'type' => 'numeric', 'shape' => 'matrix' }
    check_arg_types(args, [spec])
    check_square(dims)
    Matrix.new(dims.clone, args[0].inverse_values)
  end
end

# function LEFT
class FunctionLeft < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [2])
    args = stack.pop
    specs = [
      { 'type' => 'text', 'shape' => 'scalar' },
      { 'type' => 'numeric', 'shape' => 'scalar' }
    ]
    check_arg_types(args, specs)
    value = args[0].to_v
    count = args[1].to_i
    raise(BASICException, "Invalid count for #{@name}()") if count < 0
    text = value[0..count].chop
    quoted = '"' + text + '"'
    token = TextConstantToken.new(quoted)
    TextConstant.new(token)
  end
end

# function LEN
class FunctionLen < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'text', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    text = args[0].to_v
    length = text.size
    token = NumericConstantToken.new(length.to_s)
    NumericConstant.new(token)
  end
end

# function LOG
class FunctionLog < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    args[0].log
  end
end

# function MID
class FunctionMid < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [3])
    args = stack.pop
    specs = [
      { 'type' => 'text', 'shape' => 'scalar' },
      { 'type' => 'numeric', 'shape' => 'scalar' },
      { 'type' => 'numeric', 'shape' => 'scalar' }
    ]
    check_arg_types(args, specs)
    value = args[0].to_v
    start = args[1].to_i
    raise(BASICException, "Invalid start index for #{@name}()") if start < 1
    start -= 1
    end_index = args[2].to_i - 1
    raise(BASICException, "Invalid end index for #{@name}()") if
      end_index < start
    text = value[start..end_index]
    text = '' if text.nil?
    quoted = '"' + text + '"'
    token = TextConstantToken.new(quoted)
    TextConstant.new(token)
  end
end

# function STR$ and NUM$
class FunctionStr < AbstractScalarFunction
  def initialize(text)
    super
  end

  # return a single value
  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    text = args[0].to_s
    quoted = '"' + text + '"'
    token = TextConstantToken.new(quoted)
    TextConstant.new(token)
  end
end

# function PACK
class FunctionPack < AbstractArrayFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'array' }
    check_arg_types(args, [spec])
    array = args[0]
    dims = array.dimensions
    raise(BASICException, @name + ' requires array') unless dims.size == 1
    array.pack
  end
end

# function RIGHT
class FunctionRight < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [2])
    args = stack.pop
    specs = [
      { 'type' => 'text', 'shape' => 'scalar' },
      { 'type' => 'numeric', 'shape' => 'scalar' }
    ]
    check_arg_types(args, specs)
    value = args[0].to_v
    count = args[1].to_i
    raise(BASICException, "Invalid count for #{@name}()") if count < 0
    start = value.size - count
    start = 0 if start < 0
    text = value[start..-1]
    quoted = '"' + text + '"'
    token = TextConstantToken.new(quoted)
    TextConstant.new(token)
  end
end

# function RND
class FunctionRnd < AbstractScalarFunction
  def initialize(text)
    super
  end

  # return a single value
  def evaluate(interpreter, stack, _)
    stack.push([NumericConstant.new(1)]) unless previous_is_array(stack)
    ensure_argument_count(stack, [0, 1])
    args = stack.pop
    args = [NumericConstant.new(1)] if args.empty? || args[0].nil?
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    interpreter.rand(args[0])
  end
end

# function SGN
class FunctionSgn < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    args[0].sign
  end
end

# function SIN
class FunctionSin < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    args[0].sin
  end
end

# function SQR
class FunctionSqr < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    args[0].sqrt
  end
end

# function TAB
class FunctionTab < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(interpreter, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    console_io = interpreter.console_io
    width = console_io.columns_to_advance(args[0].to_v)
    if width > 0
      spaces = ' ' * width
    elsif width < 0
      spaces = "\b" * -width
    else
      spaces = ''
    end
    quoted = '"' + spaces + '"'
    v = TextConstantToken.new(quoted)
    TextConstant.new(v)
  end
end

# function TAN
class FunctionTan < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    args[0].tan
  end
end

# function TRN
class FunctionTrn < AbstractMatrixFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'matrix' }
    check_arg_types(args, [spec])
    dims = args[0].dimensions
    new_dims = [dims[1], dims[0]]
    Matrix.new(new_dims, args[0].transpose_values)
  end
end

# function UNPACK
class FunctionUnpack < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'text', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    text = args[0]
    text.unpack
  end
end

# function VAL
class FunctionVal < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1])
    args = stack.pop
    spec = { 'type' => 'text', 'shape' => 'scalar' }
    check_arg_types(args, [spec])
    f = args[0].to_v.to_f
    token = NumericConstantToken.new(f)
    NumericConstant.new(token)
  end
end

# function ZER
class FunctionZer < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack, _)
    ensure_argument_count(stack, [1, 2])
    args = stack.pop
    spec = { 'type' => 'numeric', 'shape' => 'scalar' }
    check_arg_types(args, [spec] * args.size)
    matrix = Matrix.new(args.clone, {})
    Matrix.new(matrix.dimensions, matrix.zero_values)
  end
end

# class to make functions, given the name
class FunctionFactory
  @functions = {
    'ABS' => FunctionAbs,
    'ASC' => FunctionAsc,
    'ATN' => FunctionAtn,
    'CHR$' => FunctionChr,
    'CON' => FunctionCon,
    'COS' => FunctionCos,
    'DET' => FunctionDet,
    'EXP' => FunctionExp,
    'EXT$' => FunctionExt,
    'IDN' => FunctionIdn,
    'INSTR' => FunctionInstr,
    'INT' => FunctionInt,
    'INV' => FunctionInv,
    'LEFT' => FunctionLeft,
    'LEN' => FunctionLen,
    'LOG' => FunctionLog,
    'MID' => FunctionMid,
    'NUM$' => FunctionStr,
    'PACK$' => FunctionPack,
    'RIGHT' => FunctionRight,
    'RND' => FunctionRnd,
    'SGN' => FunctionSgn,
    'SIN' => FunctionSin,
    'SQR' => FunctionSqr,
    'STR$' => FunctionStr,
    'TAB' => FunctionTab,
    'TAN' => FunctionTan,
    'TRN' => FunctionTrn,
    'UNPACK' => FunctionUnpack,
    'VAL' => FunctionVal,
    'ZER' => FunctionZer
  }

  def self.valid?(text)
    @functions.key?(text)
  end

  def self.make(text)
    @functions[text].new(text) if @functions.key?(text)
  end

  def self.function_names
    @functions.keys
  end
end
