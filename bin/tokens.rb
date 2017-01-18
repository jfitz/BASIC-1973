# abstract token
class AbstractToken
  def initialize
    @is_keyword = false
    @is_operator = false
    @is_separator = false
    @is_function = false
    @is_text_constant = false
    @is_numeric_constant = false
    @is_boolean_constant = false
    @is_user_function = false
    @is_variable = false
    @is_statement_separator = false
    @is_groupstart = false
    @is_groupend = false
    @is_whitespace = false
    @is_invalid = false
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

  def boolean_constant?
    @is_boolean_constant
  end

  def user_function?
    @is_user_function
  end

  def variable?
    @is_variable
  end

  def groupstart?
    @is_groupstart
  end

  def groupend?
    @is_groupend
  end

  def whitespace?
    @is_whitespace
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
    @is_invalid = true
    @text = text
  end

  def to_s
    @text
  end
end

# break token
class BreakToken < AbstractToken
  def initialize(text)
    @text = text
  end

  def to_s
    @text
  end
end

# whitespace token
class WhitespaceToken < AbstractToken
  def initialize(text)
    @is_whitespace = true
    @text = text
  end

  def to_s
    @text
  end
end

# keyword token
class KeywordToken < AbstractToken
  def initialize(text)
    @is_keyword = true
    @text = text
  end

  def to_s
    @text
  end
end

# statement separator token
class StatementSeparatorToken < AbstractToken
  def initialize(text)
    @is_statement_separator = true
    @text = text
  end

  def to_s
    @text
  end
end

# operator token
class OperatorToken < AbstractToken
  def initialize(text)
    @is_operator = true
    @text = text
  end

  def equals?
    @text == '='
  end

  def comparison?
    @text == '<' || @text == '<=' ||
      @text == '>' || @text == '>=' ||
      @text == '=' || @text == '<>'
  end

  def to_s
    @text
  end
end

# group start token
class GroupStartToken < AbstractToken
  def initialize(text)
    @is_groupstart = true
    @text = text
  end

  def to_s
    @text
  end
end

# group end token
class GroupEndToken < AbstractToken
  def initialize(text)
    @is_groupend = true
    @text = text
  end

  def to_s
    @text
  end
end

# parameter separator token
class ParamSeparatorToken < AbstractToken
  def initialize(text)
    @is_separator = true
    @text = text
  end

  def to_s
    @text
  end
end

# function token
class FunctionToken < AbstractToken
  def initialize(text)
    @is_function = true
    @text = text
  end

  def to_s
    @text
  end
end

# text constant token
class TextConstantToken < AbstractToken
  def initialize(text)
    @is_text_constant = true
    @text = text
  end

  def to_s
    @text
  end

  def value
    @text[1..-2]
  end
end

# numeric constant token
class NumericConstantToken < AbstractToken
  def initialize(text)
    @is_numeric_constant = true
    @text = text
  end

  def to_f
    @text.to_f
  end

  def to_i
    @text.to_f.to_i
  end

  def to_s
    @text
  end
end

# boolean constant token
class BooleanConstantToken < AbstractToken
  def initialize(text)
    @is_boolean_constant = true
    @text = text
  end

  def to_s
    @text
  end
end

# user function token
class UserFunctionToken < AbstractToken
  def initialize(text)
    @is_user_function = true
    @text = text
  end

  def to_s
    @text
  end
end

# variable token
class VariableToken < AbstractToken
  attr_reader :text
  
  def initialize(text)
    @is_variable = true
    @text = text
  end

  def eql?(other)
    @text == other.text
  end

  def ==(other)
    @text == other.text
  end

  def hash
    @text.hash
  end

  def content_type
    return 'TextConstant' if @text.include?('$')
    'NumericConstant'
  end

  def to_s
    @text
  end
end
