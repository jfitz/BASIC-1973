# Function that expects scalar parameters
class AbstractScalarFunction < Function
  def initialize(text)
    super
  end

  def default_type
    ScalarValue
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

# function INT
class FunctionInt < AbstractScalarFunction
  def initialize(text)
    super
  end

  # return a single value
  def evaluate(interpreter, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'])
    interpreter.int_floor? ? args[0].floor : args[0].truncate
  end
end

# function RND
class FunctionRnd < AbstractScalarFunction
  def initialize(text)
    super
  end

  # return a single value
  def evaluate(interpreter, stack)
    stack.push([NumericConstant.new(100)]) unless previous_is_array(stack)
    ensure_argument_count(stack, [0, 1])
    args = stack.pop
    args = [NumericConstant.new(100)] if args.empty? || args[0].nil?
    check_arg_types(args, ['NumericConstant'])
    interpreter.rand(args[0])
  end
end

# function EXP
class FunctionExp < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'])
    args[0].exp
  end
end

# function LOG
class FunctionLog < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'])
    args[0].log
  end
end

# function ABS
class FunctionAbs < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'])
    args[0].abs
  end
end

# function SQR
class FunctionSqr < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'])
    args[0].sqrt
  end
end

# function SIN
class FunctionSin < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'])
    args[0].sin
  end
end

# function COS
class FunctionCos < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'])
    args[0].cos
  end
end

# function TAN
class FunctionTan < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'])
    args[0].tan
  end
end

# function ATN
class FunctionAtn < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'])
    args[0].atn
  end
end

# function SGN
class FunctionSgn < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'])
    args[0].sign
  end
end

# function TRN
class FunctionTrn < AbstractMatrixFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['Matrix'])
    dims = args[0].dimensions
    new_dims = [dims[1], dims[0]]
    Matrix.new(new_dims, args[0].transpose_values)
  end
end

# function ZER
class FunctionZer < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1, 2])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'] * args.size)
    matrix = Matrix.new(args.clone, {})
    Matrix.new(matrix.dimensions, matrix.zero_values)
  end
end

# function CON
class FunctionCon < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1, 2])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'] * args.size)
    matrix = Matrix.new(args.clone, {})
    Matrix.new(matrix.dimensions, matrix.one_values)
  end
end

# function IDN
class FunctionIdn < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1, 2])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'] * args.size)
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

# function DET
class FunctionDet < AbstractMatrixFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['Matrix'])
    args[0].determinant
  end
end

# function INV
class FunctionInv < AbstractMatrixFunction
  def initialize(text)
    super
  end

  def evaluate(_, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    dims = args[0].dimensions
    check_arg_types(args, ['Matrix'])
    check_square(dims)
    Matrix.new(dims.clone, args[0].inverse_values)
  end
end

# function TAB
class FunctionTab < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(interpreter, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'])
    printer = interpreter.printer
    width = printer.columns_to_advance(args[0].to_v)
    spaces = ' ' * width
    quoted = '"' + spaces + '"'
    v = TextConstantToken.new(quoted)
    TextConstant.new(v)
  end
end

# function CHR$
class FunctionChr < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(interpreter, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['NumericConstant'])
    value = args[0].to_i
    raise(BASICException, 'Invalid value for CHR$()') if
      !value.between?(32, 126)
    text = value.chr
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

  def evaluate(interpreter, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['TextConstant'])
    text = args[0].to_v
    length = text.size
    token = NumericConstantToken.new(length.to_s)
    NumericConstant.new(token)
  end
end

# function ASC
class FunctionAsc < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(interpreter, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['TextConstant'])
    text = args[0].to_v
    raise(BASICException, 'Empty string in ASC()') if text.empty?
    value = text[0].ord
    raise(BASICException, 'Invalid value in ASC()') if !value.between?(32, 126)
    token = NumericConstantToken.new(value.to_s)
    NumericConstant.new(token)
  end
end

# function PACK
class FunctionPack < AbstractArrayFunction
  def initialize(text)
    super
  end

  def evaluate(interpreter, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['BASICArray'])
    array = args[0]
    dims = array.dimensions
    raise(BASICException, @name + ' requires array') unless dims.size == 1
    result = array.pack
    quoted = '"' + result + '"'
    token = TextConstantToken.new(quoted)
    TextConstant.new(token)
  end
end

# function UNPACK
class FunctionUnpack < AbstractScalarFunction
  def initialize(text)
    super
  end

  def evaluate(interpreter, stack)
    ensure_argument_count(stack, [1])
    args = stack.pop
    check_arg_types(args, ['TextConstant'])
    text = args[0].to_v
    length = NumericConstant.new(text.size)
    dims = [length]
    values = {}
    values[[NumericConstant.new(0)]] = length
    index = 1
    text.each_char do |char|
      key = [NumericConstant.new(index)]
      values[key] = NumericConstant.new(char.ord)
      index += 1
    end
    BASICArray.new(dims, values)
  end
end
