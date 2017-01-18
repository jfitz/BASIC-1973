# tests for StatementSeparatorToken class

require 'test/unit'

require_relative '../bin/tokens'

class TestStatementSeparatorToken < Test::Unit::TestCase

  def test_colon
    token = StatementSeparatorToken.new(':')

    assert_equal(':', token.to_s)

    assert(!token.keyword?)
    assert(!token.operator?)
    assert(!token.separator?)
    assert(!token.function?)
    assert(!token.text_constant?)
    assert(!token.numeric_constant?)
    assert(!token.boolean_constant?)
    assert(!token.user_function?)
    assert(!token.variable?)
    assert(!token.groupstart?)
    assert(!token.groupend?)
    assert(!token.whitespace?)
    assert(!token.operand?)
    assert(token.statement_separator?)
  end
  
  def test_backslash
    token = StatementSeparatorToken.new('\\')

    assert_equal('\\', token.to_s)

    assert(!token.keyword?)
    assert(!token.operator?)
    assert(!token.separator?)
    assert(!token.function?)
    assert(!token.text_constant?)
    assert(!token.numeric_constant?)
    assert(!token.boolean_constant?)
    assert(!token.user_function?)
    assert(!token.variable?)
    assert(!token.groupstart?)
    assert(!token.groupend?)
    assert(!token.whitespace?)
    assert(!token.operand?)
    assert(token.statement_separator?)
  end
  
end
