# accept any characters
class InvalidTokenBuilder
  def try(text)
    @token = ''
    @token += text.empty? ? '' : text[0]
  end

  def count
    @token.size
  end

  def token
    InvalidToken.new(@token)
  end
end

# accept characters to match item in list
class ListTokenBuilder
  attr_reader :count

  def initialize(legals, class_name)
    @legals = legals
    @class = class_name
    @count = 0
  end

  def try(text)
    best_candidate = ''
    best_count = 0
    if !text.empty? && text[0] != ' '
      candidate = ''
      i = 0
      accepted = true
      while i < text.size && accepted
        c = text[i]
        # ignore space char
        if c == ' '
          i += 1
        else
          accepted = accept?(candidate, c)
          if accepted
            candidate += c
            i += 1
            if @legals.include?(candidate)
              best_candidate = candidate
              best_count = i
            end
          end
        end
      end
    end

    @count = 0
    unless best_candidate.empty?
      @token = best_candidate
      @count = best_count
    end

    !@count.zero?
  end

  def token
    @class.new(@token)
  end

  private

  def accept?(candidate, c)
    token = candidate + c
    count = token.size - 1
    result = false

    @legals.each do |legal|
      result = true if legal[0..count] == token
    end

    result
  end
end

# Remark tokens (returns 2)
class RemarkTokenBuilder
  attr_reader :count

  def initialize
    @legals = %w(REMARK REM)
    @count = 0
  end

  def try(text)
    best_candidate = ''
    best_count = 0
    if !text.empty? && text[0] != ' '
      candidate = ''
      i = 0
      accepted = true
      while i < text.size && accepted
        c = text[i]
        # ignore space char
        if c == ' '
          i += 1
        else
          accepted = accept?(candidate, c)
          if accepted
            candidate += c
            i += 1
            if @legals.include?(candidate)
              best_candidate = candidate
              best_count = i
            end
          end
        end
      end
    end

    @count = 0
    unless best_candidate.empty?
      @keyword_token = best_candidate
      remark = text[best_count..-1]
      @remark_token = remark[0] == ' ' ? remark[1..-1] : remark
      @count = text.size
    end

    !@count.zero?
  end

  def token
    tokens = []
    tokens << KeywordToken.new(@keyword_token)
    tokens << RemarkToken.new(@remark_token) unless @remark_token.empty?
    tokens
  end

  private

  def accept?(candidate, c)
    token = candidate + c
    count = token.size - 1
    result = false

    @legals.each do |legal|
      result = true if legal[0..count] == token
    end

    result
  end
end

# token reader for whitespace
class WhitespaceTokenBuilder
  def try(text)
    @token = ''
    /\A\s+/.match(text) { |m| @token = m[0] }
  end

  def count
    @token.size
  end

  def token
    WhitespaceToken.new(@token)
  end
end

# token reader for comments
class CommentTokenBuilder
  attr_reader :count

  def initialize(lead_chars)
    @lead_chars = lead_chars
  end

  def try(text)
    @token = ''
    @token = text if !text.empty? && @lead_chars.include?(text[0])

    @count = @token.size
  end

  def token
    CommentToken.new(@token)
  end
end

# token reader for text constants
class TextTokenBuilder
  attr_reader :count

  def try(text)
    @token = ''
    candidate = ''
    i = 0
    if !text.empty? && text[0] == '"'
      until i == text.size || candidate.count('"') == 2
        c = text[i]
        candidate += c
        i += 1
      end
    end

    candidate += '"' if candidate.count('"') == 1
    @token = candidate if candidate.count('"') == 2
    @count = @token.size
  end

  def token
    TextConstantToken.new(@token)
  end
end

# token reader for numeric constants in input channels (READ, INPUT)
class InputNumberTokenBuilder
  def try(text)
    regexes = [
      /\A[+-]?\d+/,
      /\A[+-]?\d+\./,
      /\A[+-]?\d+E[+-]?\d+/,
      /\A[+-]?\d+\.E[+-]?\d+/,
      /\A[+-]?\d+\.\d+/,
      /\A[+-]?\d+\.\d+E[+-]?\d+/,
      /\A[+-]?\.\d+/,
      /\A[+-]?\.\d+E[+-]?\d+/
    ]

    @token = ''

    regexes.each { |regex| regex.match(text) { |m| @token = m[0] } }
  end

  def count
    @token.size
  end

  def token
    NumericConstantToken.new(@token)
  end
end

# token reader for numeric constants
class NumberTokenBuilder
  attr_reader :count

  def initialize(allow_hash_constant)
    @allow_hash_constant = allow_hash_constant
  end

  def try(text)
    if text.size >= 2 && text[0..1] == 'PI'
      candidate = 'PI'
      i = 2
    elsif @allow_hash_constant && text.size >= 2 && text[0] == '#'
      candidate = text[0..1]
      i = 2
    else
      candidate = ''
      if !text.empty? && text[0] != ' '
        i = 0
        accepted = true
        while i < text.size && accepted
          c = text[i]
          # ignore space char
          if c == ' '
            i += 1
          else
            accepted = accept?(candidate, c)
            if accepted
              candidate += c
              i += 1
            end
          end
        end
      end

      # if the candidate ends with 'E', remove it
      # the tokenizer takes as many as possible,
      # but a trailing 'E' is not valid
      if candidate[-1] == 'E'
        candidate = candidate[0..-2]
        i -= 1

        # back up to the 'E' in the input text
        # (there may be spaces)
        i -= 1 while text[i] != 'E'
      end
    end

    # check that string conforms to one of these
    regexes = [
      /PI/,
      /#./,
      /\A\d+\z/,
      /\A\d+\.\z/,
      /\A\d+E[+-]?\d+\z/,
      /\A\d+\.E[+-]?\d+\z/,
      /\A\d+\.\d+(E[+-]?\d+)?\z/,
      /\A\.\d+(E[+-]?\d+)?\z/
    ]

    @token = ''
    regexes.each { |regex| regex.match(candidate) { |m| @token = m[0] } }
    @count = 0
    @count = i unless @token.empty?
    !@count.zero?
  end

  def token
    NumericConstantToken.new(@token)
  end

  private

  def accept?(candidate, c)
    result = false

    if candidate.size .zero? || candidate[0] != '#'
      # can always append a digit
      result = true if c =~ /[0-9]/
      # can append a decimal point if no decimal point and no E
      result = true if c == '.' && candidate.count('.', 'E').zero?
      # can append E if no E and at least one digit (not just decimal point)
      result = true if c == 'E' &&
                       candidate.count('E').zero? &&
                       !candidate.count('0-9').zero?
      # can append sign if no chars or last char was E
      result = true if c == '+' && (candidate.empty? || candidate[-1] == 'E')
      result = true if c == '-' && (candidate.empty? || candidate[-1] == 'E')
    else
      result = candidate.size == 1
    end

    result
  end
end

# token reader for integer constants
class IntegerTokenBuilder
  attr_reader :count

  def try(text)
    candidate = ''
    if !text.empty? && text[0] != ' '
      i = 0
      accepted = true
      while i < text.size && accepted
        c = text[i]
        # ignore space char
        if c == ' '
          i += 1
        else
          accepted = accept?(candidate, c)
          if accepted
            candidate += c
            i += 1
          end
        end
      end
    end

    # check that string conforms to one of these
    regexes = [
      /\A\d+%/
    ]

    @token = ''
    regexes.each { |regex| regex.match(candidate) { |m| @token = m[0] } }
    @count = 0
    @count = i unless @token.empty?
    !@count.zero?
  end

  def token
    IntegerConstantToken.new(@token)
  end

  private

  def accept?(candidate, c)
    result = false
    # can always append one percent char
    result = true if c == '%' && candidate.count('%').zero?
    # can append a digit if no percent char
    result = true if c =~ /[0-9]/ && candidate.count('%').zero?

    result
  end
end

# token reader for variables
class VariableTokenBuilder
  attr_reader :count

  def try(text)
    candidate = ''
    if !text.empty? && text[0] != ' '
      i = 0
      accepted = true
      while i < text.size && accepted
        c = text[i]
        # ignore space char
        if c == ' '
          i += 1
        else
          accepted = accept?(candidate, c)
          if accepted
            candidate += c
            i += 1
          end
        end
      end
    end

    @token = ''
    # check that string conforms to one of these
    regexes = [
      /\A[A-Z]\z/,
      /\A[A-Z]\d\z/,
      /\A[A-Z]\$\z/,
      /\A[A-Z]\d\$\z/,
      /\A[A-Z]\%\z/,
      /\A[A-Z]\d\%\z/
    ]

    @token = ''
    regexes.each { |regex| regex.match(candidate) { |m| @token = m[0] } }

    @count = 0
    @count = i unless @token.empty?
    !@count.zero?
  end

  def token
    VariableToken.new(@token)
  end

  private

  def accept?(candidate, c)
    result = false
    # can always start with an alpha
    result = true if c =~ /[A-Z]/ && candidate.empty?
    # can append a digit to a single character
    result = true if c =~ /[0-9]/ && candidate.size == 1
    # can append a dollar sign if one is not there
    result = true if
      c == '$' && [1, 2].include?(candidate.size) && candidate[-1] != '$'
    # can append a percent sign if one is not there
    result = true if
      c == '%' && [1, 2].include?(candidate.size) && candidate[-1] != '%'

    result
  end
end

# token reader for text constants in input channels (READ, INPUT)
class InputTextTokenBuilder
  def try(text)
    @token = ''
    /\A"[^"]*"/.match(text) { |m| @token = m[0] }
  end

  def count
    @token.size
  end

  def token
    TextConstantToken.new(@token)
  end
end

# token reader for text constants
class InputBareTextTokenBuilder
  def try(text)
    @token = ''
    /\A[^,; ]*/.match(text) { |m| @token = m[0] }
  end

  def count
    @token.size
  end

  def token
    quoted = '"' + @token + '"'
    TextConstantToken.new(quoted)
  end
end

# token reader for token separator
class BreakTokenBuilder
  def try(text)
    @token = ''
    @token = text[0] if text[0] == '_'
  end

  def count
    @token.size
  end

  def token
    BreakToken.new(@token)
  end
end
