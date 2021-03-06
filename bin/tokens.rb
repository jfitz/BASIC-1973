# abstract token
class AbstractToken
  def self.pretty_tokens(keywords, tokens)
    pretty_tokens = []

    token1 = NullToken.new
    token2 = NullToken.new

    keywords.each do |token|
      pretty_tokens << WhitespaceToken.new(' ') unless pretty_tokens.empty?
      pretty_tokens << token

      token2 = token1
      token1 = token
    end

    tokens.each do |token|
      prev_is_variable = token1.variable? ||
                         token1.function? ||
                         token1.user_function?

      prev2_is_operand = token2.operand? || token2.group_end?

      pretty_tokens << WhitespaceToken.new(' ') unless
        token.separator? ||
        (token.group_start? && prev_is_variable) ||
        token.group_end? ||
        token1.group_start? ||
        (token1.operator? && token1.to_s != 'NOT' && !prev2_is_operand) ||
        token1.whitespace? ||
        token1.null?

      pretty_tokens << token

      token2 = token1
      token1 = token
    end

    pretty_tokens.map(&:to_s).join
  end

  def self.pretty_multiline(keywords, tokens)
    pretty_lines = []
    pretty_tokens = []

    keywords.each do |token|
      pretty_tokens << WhitespaceToken.new(' ')
      pretty_tokens << token
    end

    token1 = WhitespaceToken.new(' ')
    token2 = WhitespaceToken.new(' ')
    tokens.each do |token|
      prev_is_variable = token1.variable? ||
                         token1.function? ||
                         token1.user_function?

      prev2_is_operand = token2.operand? || token2.group_end?
      pretty_tokens << WhitespaceToken.new(' ') unless
        token.separator? ||
        (token.group_start? && prev_is_variable) ||
        token.group_end? ||
        token1.group_start? ||
        (token1.operator? && token1.to_s != 'NOT' && !prev2_is_operand)

      pretty_tokens << token
      if token.statement_separator?
        pretty_line = pretty_tokens.map(&:to_s).join
        pretty_lines << pretty_line
        pretty_tokens = []
      end

      token2 = token1
      token1 = token
    end

    pretty_line = pretty_tokens.map(&:to_s).join
    pretty_lines << pretty_line
  end

  attr_reader :text

  def initialize(text)
    @text = text.to_s
    @is_null = false
    @is_break = false
    @is_whitespace = false
    @is_comment = false
    @is_keyword = false
    @is_operator = false
    @is_separator = false
    @is_function = false
    @is_text_constant = false
    @is_numeric_constant = false
    @is_symbol_constant = false
    @is_boolean_constant = false
    @is_user_function = false
    @is_variable = false
    @is_statement_separator = false
    @is_group_start = false
    @is_group_end = false
    @is_invalid = false
  end

  def eql?(other)
    @text == other.to_s
  end

  def ==(other)
    @text == other.to_s
  end

  def hash
    @text.hash
  end

  def to_s
    @text
  end

  def null?
    @is_null
  end

  def break?
    @is_break
  end

  def whitespace?
    @is_whitespace
  end

  def comment?
    @is_comment
  end

  def keyword?
    @is_keyword
  end

  def operator?
    @is_operator
  end

  def separator?
    @is_separator
  end

  def function?
    @is_function
  end

  def text_constant?
    @is_text_constant
  end

  def numeric_constant?
    @is_numeric_constant
  end

  def symbol_constant?
    @is_symbol_constant
  end

  def boolean_constant?
    @is_boolean_constant
  end

  def user_function?
    @is_user_function
  end

  def variable?
    @is_variable
  end

  def group_start?
    @is_group_start
  end

  def group_end?
    @is_group_end
  end

  def operand?
    @is_function || @is_text_constant || @is_numeric_constant ||
      @is_boolean_constant || @is_user_function || @is_variable
  end

  def statement_separator?
    @is_statement_separator
  end

  def invalid?
    @is_invalid
  end
end

# invalid token
class InvalidToken < AbstractToken
  def initialize(text)
    super

    @is_invalid = true
  end
end

# null token used for pretty()
class NullToken < AbstractToken
  def initialize
    super('')

    @is_null = true
  end
end

# break token
class BreakToken < AbstractToken
  def initialize(text)
    super

    @is_break = true
  end
end

# whitespace token
class WhitespaceToken < AbstractToken
  def initialize(text)
    super

    @is_whitespace = true
  end
end

# keyword token
class KeywordToken < AbstractToken
  def initialize(text)
    super

    @is_keyword = true
  end
end

# comment token
class CommentToken < AbstractToken
  def initialize(text)
    super

    @is_comment = true
  end
end

# remark token
class RemarkToken < AbstractToken
  def initialize(text)
    super
  end
end

# statement separator token
class StatementSeparatorToken < AbstractToken
  def initialize(text)
    super

    @is_statement_separator = true
  end
end

# operator token
class OperatorToken < AbstractToken
  def initialize(text)
    super

    @is_operator = true
  end

  def equals?
    @text == '='
  end

  def comparison?
    @text == '<' || @text == '<=' || @text == '=<' ||
      @text == '>' || @text == '>=' || @text == '=>' ||
      @text == '=' || @text == '<>' || @text == '#'
  end

  def pound?
    @text == '#'
  end
end

# group start token
class GroupStartToken < AbstractToken
  def initialize(text)
    super

    @is_group_start = true
  end
end

# group end token
class GroupEndToken < AbstractToken
  def initialize(text)
    super

    @is_group_end = true
  end
end

# parameter separator token
class ParamSeparatorToken < AbstractToken
  def initialize(text)
    super

    @is_separator = true
  end
end

# function token
class FunctionToken < AbstractToken
  def initialize(text)
    super

    @is_function = true
  end

  def ==(other)
    @text == other.text
  end

  def hash
    @text.hash
  end

  def <=>(other)
    @text <=> other.text
  end
end

# text constant token
class TextConstantToken < AbstractToken
  def initialize(text)
    super

    @is_text_constant = true
  end

  def value
    @text[1..-2]
  end

  def <=>(other)
    value <=> other.value
  end
end

# numeric constant token
class NumericConstantToken < AbstractToken
  def initialize(text)
    super

    @is_numeric_constant = true
  end

  def negate
    @text = @text[0] == '-' ? @text[1..-1] : '-' + @text
  end

  def to_f
    @text.to_f
  end

  def to_i
    @text.to_f.to_i
  end

  def <=>(other)
    @text.to_f <=> other.to_f
  end
end

# integer constant token
class IntegerConstantToken < AbstractToken
  def initialize(text)
    super

    @is_numeric_constant = true
  end

  def negate
    @text = @text[0] == '-' ? @text[1..-1] : '-' + @text
  end

  def to_f
    @text.to_f.to_i
  end

  def to_i
    @text.to_f.to_i
  end

  def <=>(other)
    @text.to_f <=> other.to_f
  end
end

# numeric symbol token
class NumericSymbolToken < AbstractToken
  def initialize(text)
    super

    @is_numeric_constant = true
    @is_symbol_constant = true

    @values = {
      'PI' => 3.14159265358979,
      'EUL' => 2.71828182845905,
      'AUR' => 1.61803398874989
    }
  end

  def value
    @values[@text]
  end
end

# text symbol token
class TextSymbolToken < AbstractToken
  def initialize(text)
    super

    @is_text_constant = true
    @is_symbol_constant = true

    @values = {
      'NUL' => "\0",
      'SOH' => "\1",
      'STX' => "\2",
      'ETX' => "\3",
      'EOT' => "\4",
      'ENQ' => "\5",
      'ACK' => "\6",
      'BEL' => "\7",
      'BS' => "\8",
      'HT' => "\9",
      'LF' => "\10",
      'VT' => "\11",
      'FF' => "\12",
      'CR' => "\13",
      'SO' => "\14",
      'SI' => "\15",
      'DLE' => "\16",
      'DC1' => "\17",
      'DC2' => "\18",
      'DC3' => "\19",
      'DC4' => "\20",
      'NAK' => "\21",
      'SYN' => "\22",
      'ETB' => "\23",
      'CAN' => "\24",
      'EM' => "\25",
      'SUB' => "\26",
      'ESC' => "\27",
      'FS' => "\28",
      'GS' => "\29",
      'RS' => "\30",
      'US' => "\31"
    }
  end

  def value
    @values[@text]
  end
end

# boolean constant token
class BooleanConstantToken < AbstractToken
  def initialize(text)
    super

    @is_boolean_constant = true
  end

  def to_f
    @text.to_f.to_i
  end

  def to_i
    @text.to_f.to_i
  end

  def <=>(other)
    @text.to_f <=> other.to_f
  end
end

# user function token
class UserFunctionToken < AbstractToken
  attr_reader :content_type

  def initialize(text)
    super

    @is_user_function = true
    @content_type = :numeric
    @content_type = :string if text.include?('$')
    @content_type = :integer if text.include?('%')
  end

  def ==(other)
    @text == other.text
  end

  def hash
    @text.hash
  end

  def <=>(other)
    @text <=> other.text
  end
end

# variable token
class VariableToken < AbstractToken
  attr_reader :content_type

  def initialize(text)
    super

    raise(BASICSyntaxError, 'invalid token') unless text.class.to_s == 'String'
    @is_variable = true
    @content_type = :numeric
    @content_type = :string if text.include?('$')
    @content_type = :integer if text.include?('%')
  end

  def ==(other)
    @text == other.text
  end

  def hash
    @text.hash
  end

  def <=>(other)
    @text <=> other.text
  end
end

# PRINT USING token for numeric
class NumericFormatToken < AbstractToken
  def initialize(text)
    super
  end

  def wants_item
    true
  end

  def format(numeric_constant)
    width = @text.size

    if @text.include?('.')
      parts = @text.split('.')
      decimals = parts[1].size
      spec = '%' + width.to_s + '.' + decimals.to_s + 'f'
    else
      spec = '%' + width.to_s + '.0f'
    end

    text = sprintf(spec, numeric_constant.to_v)

    text.tr!(' ', '*') if @text.include?('*')
    TextConstant.new(text)
  end
end

# PRINT USING token for character
class CharFormatToken < AbstractToken
  def initialize(text)
    super
  end

  def wants_item
    true
  end

  def format(text_constant)
    text = text_constant.to_v
    text = text[0]
    TextConstant.new(text)
  end
end

# PRINT USING token for plain string
class PlainStringFormatToken < AbstractToken
  def initialize(text)
    super
  end

  def wants_item
    true
  end

  def format(text_constant)
    text = text_constant.to_v
    TextConstant.new(text)
  end
end

# PRINT USING token for padded string
class PaddedStringFormatToken < AbstractToken
  def initialize(text)
    super
  end

  def wants_item
    true
  end

  def format(text_constant)
    text = text_constant.to_v
    text += ' ' while text.size < @text.size
    TextConstant.new(text)
  end
end

# PRINT USING token for constant text
class ConstantFormatToken < AbstractToken
  def initialize(text)
    super
  end

  def wants_item
    false
  end

  def format(text_constant)
    TextConstant.new(@text)
  end
end
