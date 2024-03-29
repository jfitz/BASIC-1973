# frozen_string_literal: true

# Modifier
class AbstractModifier
  attr_reader :errors, :warnings, :numerics, :strings, :booleans, :variables,
              :operators, :functions, :userfuncs, :pre_comp_effort,
              :post_comp_effort, :mccabe, :profile_pre_count,
              :profile_post_count, :profile_pre_time, :profile_post_time,
              :cond, :loop

  def initialize(tokens_lists)
    @tokens = tokens_lists.flatten
    @cond = false
    @loop = false
    @errors = []
    @warnings = []
    @profile_pre_count = 0
    @profile_post_count = 0
    @profile_pre_time = 0
    @profile_post_time = 0
    @mccabe = 1
    @pre_comp_effort = 0
    @post_comp_effort = 0
  end

  # called for the post-modifiers
  def set_destinations(_, _) end

  def reset_profile_metrics
    @profile_pre_count = 0
    @profile_post_count = 0
    @profile_pre_time = 0
    @profile_post_time = 0
  end

  def pretty
    AbstractToken.pretty_tokens([], @tokens)
  end

  def pre_analyze
    "(#{@mccabe} #{@pre_comp_effort})   #{pretty}"
  end

  def execute_pre(interpreter)
    timing = Benchmark.measure { execute_pre_stmt(interpreter) }

    user_time = timing.utime + timing.cutime
    sys_time = timing.stime + timing.cstime
    time = user_time + sys_time

    @profile_pre_time += time
    @profile_pre_count += 1
  end

  def execute_post(interpreter)
    timing = Benchmark.measure { execute_post_stmt(interpreter) }

    user_time = timing.utime + timing.cutime
    sys_time = timing.stime + timing.cstime
    time = user_time + sys_time

    @profile_post_time += time
    @profile_post_count += 1
  end

  private

  # get opposite modifier (pre- when in post; post- when in pre)
  def get_counterpart(interpreter)
    current_line_stmt_mod = interpreter.current_line_stmt_mod
    line_number = current_line_stmt_mod.line_number
    stmt = current_line_stmt_mod.statement
    mod = current_line_stmt_mod.index
    other_mod = -mod
    LineStmtMod.new(line_number, stmt, other_mod)
  end

  def execute_pre_stmt(_); end

  def execute_post_stmt(_); end
end

# IF
class IfModifier < AbstractModifier
  def self.lead_keywords
    [
      [KeywordToken.new('IF')]
    ]
  end

  def initialize(tokens_lists)
    super(tokens_lists)

    @cond = true

    expression_tokens = tokens_lists.last
    @expression = ValueExpressionSet.new(expression_tokens, :scalar)
    @errors << 'TAB() not allowed' if @expression.has_tab
    @warnings << 'Constant expression' if @expression.constant?

    @numerics = @expression.numerics
    @strings = @expression.strings
    @booleans = @expression.booleans
    @variables = @expression.variables
    @operators = @expression.operators
    @functions = @expression.functions
    @userfuncs = @expression.userfuncs

    @pre_comp_effort = @expression.comprehension_effort
    @post_comp_effort = 1
  end

  def uncache
    @expression.uncache
  end

  def pre_pretty
    "IF #{@expression}"
  end

  def post_pretty
    'ENDIF'
  end

  def post_analyze
    "(0 1)   ENDIF"
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?
    lines += @statement.dump unless @statement.nil?
    lines += @else_stmt.dump unless @else_stmt.nil?

    lines
  end

  private

  def execute_pre_stmt(interpreter)
    io = interpreter.trace_out

    values = @expression.evaluate(interpreter)
    raise(BASICExpressionError, 'Too many values') unless
      values.size == 1

    result = values[0]
    result = BooleanValue.new(result) unless
      result.class.to_s == 'BooleanValue'

    s = " #{result}"
    io.trace_output(s)

    # if true then continue execution normally
    return if result.value

    # if false then transfer to our post modifier
    interpreter.next_line_stmt_mod = get_counterpart(interpreter)
  end
end

# UNLESS
class UnlessModifier < AbstractModifier
  def self.lead_keywords
    [
      [KeywordToken.new('UNLESS')]
    ]
  end

  def initialize(tokens_lists)
    super

    @cond = true

    expression_tokens = tokens_lists.last
    @expression = ValueExpressionSet.new(expression_tokens, :scalar)
    @errors << 'TAB() not allowed' if @expression.has_tab
    @warnings << 'Constant expression' if @expression.constant?

    @numerics = @expression.numerics
    @strings = @expression.strings
    @booleans = @expression.booleans
    @variables = @expression.variables
    @operators = @expression.operators
    @functions = @expression.functions
    @userfuncs = @expression.userfuncs

    @pre_comp_effort = @expression.comprehension_effort
    @post_comp_effort = 1
  end

  def uncache
    @expression.uncache
  end

  def pre_pretty
    "UNLESS #{@expression}"
  end

  def post_pretty
    'ENDUNLESS'
  end

  def post_analyze
    "(0 1)   ENDUNLESS"
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?
    lines += @statement.dump unless @statement.nil?
    lines += @else_stmt.dump unless @else_stmt.nil?

    lines
  end

  private

  def execute_pre_stmt(interpreter)
    io = interpreter.trace_out

    values = @expression.evaluate(interpreter)
    raise(BASICExpressionError, 'Too many values') unless
      values.size == 1

    result = values[0]
    result = BooleanValue.new(result) unless
      result.class.to_s == 'BooleanValue'

    s = " #{result}"
    io.trace_output(s)

    # if false then continue execution normally
    return unless result.value

    # if true then transfer to our post modifier
    interpreter.next_line_stmt_mod = get_counterpart(interpreter)
  end
end

# WHILE
class WhileModifier < AbstractModifier
  def self.lead_keywords
    [
      [KeywordToken.new('WHILE')]
    ]
  end

  def initialize(tokens_lists)
    super

    @loop = true

    expression_tokens = tokens_lists.last
    @expression = ValueExpressionSet.new(expression_tokens, :scalar)
    @errors << 'TAB() not allowed' if @expression.has_tab
    @warnings << 'Constant expression' if @expression.constant?

    @numerics = @expression.numerics
    @strings = @expression.strings
    @booleans = @expression.booleans
    @variables = @expression.variables
    @operators = @expression.operators
    @functions = @expression.functions
    @userfuncs = @expression.userfuncs

    @pre_comp_effort = @expression.comprehension_effort
    @post_comp_effort = 1
  end

  def uncache
    @expression.uncache
  end

  # called for the post-modifiers
  def set_destinations(line_stmt_mod, program)
    # address of the END WHILE
    @wendstmt_line_stmt_mod = line_stmt_mod

    # address of the WHILE + 1
    pre_line_stmt_mod = line_stmt_mod.get_counterpart
    @loopstart_line_stmt_mod = program.find_next_line_stmt_mod(pre_line_stmt_mod)
  end

  def pre_pretty
    "WHILE #{@expression}"
  end

  def post_pretty
    'ENDWHILE'
  end

  def post_analyze
    "(0 1)   ENDWHILE"
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?
    lines += @statement.dump unless @statement.nil?
    lines += @else_stmt.dump unless @else_stmt.nil?

    lines
  end

  private

  def execute_pre_stmt(interpreter)
    io = interpreter.trace_out

    while_control = WhileControl.new(:while, @expression,
                                     @loopstart_line_stmt_mod)

    interpreter.enter_loop(while_control)

    terminated = while_control.terminated?(interpreter)
    io.trace_output(" terminated: #{terminated}")

    # if terminated then transfer to our post modifier
    interpreter.next_line_stmt_mod = @wendstmt_line_stmt_mod if terminated
  end

  def execute_post_stmt(interpreter)
    io = interpreter.trace_out

    while_control = interpreter.top_while
    
    terminated = while_control.terminated?(interpreter)

    if terminated
      interpreter.exit_loop(while_control)
    else
      # if not terminated then go to start of while
      interpreter.next_line_stmt_mod = while_control.start_line_stmt_mod
    end
  end
end

# UNTIL
class UntilModifier < AbstractModifier
  def self.lead_keywords
    [
      [KeywordToken.new('UNTIL')]
    ]
  end

  def initialize(tokens_lists)
    super

    @loop = true

    expression_tokens = tokens_lists.last
    @expression = ValueExpressionSet.new(expression_tokens, :scalar)
    @errors << 'TAB() not allowed' if @expression.has_tab
    @warnings << 'Constant expression' if @expression.constant?

    @numerics = @expression.numerics
    @strings = @expression.strings
    @booleans = @expression.booleans
    @variables = @expression.variables
    @operators = @expression.operators
    @functions = @expression.functions
    @userfuncs = @expression.userfuncs

    @pre_comp_effort = @expression.comprehension_effort
    @post_comp_effort = 1
  end

  def uncache
    @expression.uncache
  end

  # called for the post-modifiers
  def set_destinations(line_stmt_mod, program)
    # address of the END UNTIL
    @wendstmt_line_stmt_mod = line_stmt_mod

    # address of the UNTIL + 1
    pre_line_stmt_mod = line_stmt_mod.get_counterpart
    @loopstart_line_stmt_mod = program.find_next_line_stmt_mod(pre_line_stmt_mod)
  end

  def pre_pretty
    "UNTIL #{@expression}"
  end

  def post_pretty
    'ENDUNTIL'
  end

  def post_analyze
    "(0 1)   ENDUNTIL"
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?
    lines += @statement.dump unless @statement.nil?
    lines += @else_stmt.dump unless @else_stmt.nil?

    lines
  end

  private

  def execute_pre_stmt(interpreter)
    io = interpreter.trace_out

    until_control = WhileControl.new(:until, @expression,
                                     @loopstart_line_stmt_mod)

    interpreter.enter_loop(until_control)

    terminated = until_control.terminated?(interpreter)
    io.trace_output(" terminated: #{terminated}")

    # if terminated then transfer to our post modifier
    interpreter.next_line_stmt_mod = @wendstmt_line_stmt_mod if terminated
  end

  def execute_post_stmt(interpreter)
    io = interpreter.trace_out

    until_control = interpreter.top_until

    terminated = until_control.terminated?(interpreter)
    io.trace_output(" terminated: #{terminated}")

    if terminated
      interpreter.exit_loop(until_control)
    else
      # if not terminated then go to start of while
      interpreter.next_line_stmt_mod = until_control.start_line_stmt_mod
    end
  end
end

# FOR
class AbstractForModifier < AbstractModifier
  def self.lead_keywords
    [
      [KeywordToken.new('FOR')]
    ]
  end

  def initialize(tokens_lists, control_and_start_tokens, _step_tokens, _end_tokens, _until_tokens, _while_tokens)
    super(tokens_lists)

    @loop = true

    parts = split_on_token(control_and_start_tokens, '=')

    raise(BASICSyntaxError, 'Incorrect initialization') if
      parts.size != 3

    raise(BASICSyntaxError, 'Missing "=" sign') if
      parts[1].to_s != '='

    control_tokens = parts[0]
    start_tokens = parts[2]

    @errors << 'Control variable must be a variable' unless
      control_tokens.class.to_s == 'Array' &&
      !control_tokens.empty? &&
      control_tokens[0].variable?

    control_name = VariableName.new(control_tokens[0])
    @control_variable = Variable.new(control_name, :scalar, [], [])
    @start = ValueExpressionSet.new(start_tokens, :scalar)

    @errors << 'TAB() not allowed' if @start.has_tab

    xref = XrefEntry.new(@control_variable.to_s, nil, true)

    @numerics = @start.numerics
    @strings = @start.strings
    @booleans = @start.booleans
    @variables = [xref] + @start.variables
    @operators = @start.operators
    @functions = @start.functions
    @userfuncs = @start.userfuncs

    @pre_comp_effort = @start.comprehension_effort
    @post_comp_effort = 1
  end

  # called for the post-modifiers
  def set_destinations(line_stmt_mod, program)
    # address of NEXT
    @nextstmt_line_stmt_mod = line_stmt_mod

    # address of FOR + 1
    pre_line_stmt_mod = line_stmt_mod.get_counterpart
    @loopstart_line_stmt_mod = program.find_next_line_stmt_mod(pre_line_stmt_mod)
  end

  def post_pretty
    "NEXT #{@control_variable}"
  end

  def post_analyze
    "(0 1)   NEXT #{@control_variable}"
  end

  def post_trace
    "NEXT #{@control_variable}"
  end

  private

  def execute_pre_stmt(interpreter)
    from = @start.evaluate(interpreter)[0]
    step = NumericValue.new(1)
    step = @step.evaluate(interpreter)[0] unless @step.nil?

    unless @end.nil?
      to = @end.evaluate(interpreter)[0]

      fornext_control =
        ForToControl.new(@control_variable, from, step, to,
                         @loopstart_line_stmt_mod)
    end

    unless @until.nil?
      fornext_control =
        ForUntilControl.new(@control_variable, from, step, @until,
                            @loopstart_line_stmt_mod)
    end

    unless @while.nil?
      fornext_control =
        ForWhileControl.new(@control_variable, from, step, @while,
                            @loopstart_line_stmt_mod)
    end

    interpreter.assign_fornext(fornext_control)
    interpreter.enter_loop(fornext_control)

    terminated = fornext_control.front_terminated?(interpreter)

    io = interpreter.trace_out
    print_trace_info(io, terminated)

    # front-terminated; go to post-exec of this modifier
    interpreter.next_line_stmt_mod = @nextstmt_line_stmt_mod if terminated
  end

  def execute_post_stmt(interpreter)
    fornext_control = interpreter.retrieve_fornext(@control_variable)

    bump_early = fornext_control.bump_early?

    # change control variable value for FOR-WHILE and FOR-UNTIL
    fornext_control.bump_control(interpreter) if bump_early

    terminated = fornext_control.terminated?(interpreter)
    io = interpreter.trace_out
    print_trace_info(io, terminated)

    if terminated
      interpreter.exit_loop(fornext_control)
      fornext_control.broken = false
    else
      # set next line from top item
      interpreter.next_line_stmt_mod = fornext_control.start_line_stmt_mod
      # change control variable value
      fornext_control.bump_control(interpreter) unless bump_early
    end
  end

  def split_on_token(tokens, token_to_split)
    results = []
    list = []

    tokens.each do |token|
      if token.to_s == token_to_split
        results << list unless list.empty?
        list = []
        results << token
      else
        list << token
      end
    end

    results << list unless list.empty?
    results
  end

  def print_trace_info(io, terminated)
    io.trace_output(" terminated:#{terminated}")
  end
end

class ForToModifier < AbstractForModifier
  def initialize(tokens_lists, control_and_start_tokens, end_tokens)
    step_tokens = nil
    until_tokens = nil
    while_tokens = nil

    super(tokens_lists, control_and_start_tokens, step_tokens, end_tokens, until_tokens, while_tokens)

    @end = ValueExpressionSet.new(end_tokens, :scalar)

    @errors << 'TAB() not allowed' if @end.has_tab

    @numerics += @end.numerics
    @strings += @end.strings
    @booleans += @end.booleans
    @variables += @end.variables
    @operators += @end.operators
    @functions += @end.functions
    @userfuncs += @end.userfuncs

    @pre_comp_effort = @end.comprehension_effort
    @post_comp_effort = 1
  end

  def uncache
    @start.uncache
    @end.uncache
  end

  def dump
    lines = []
    lines << ("control: #{@control_variable.dump}")
    lines << ("start:   #{@start.dump}")
    lines << ("end:     #{@end.dump}")
    lines
  end

  def pre_pretty
    "FOR #{@control_variable} = #{@start} TO #{@end}"
  end
end

class ForToStepModifier < AbstractForModifier
  def initialize(tokens_lists, control_and_start_tokens, step_tokens, end_tokens)
    until_tokens = nil
    while_tokens = nil

    super(tokens_lists, control_and_start_tokens, step_tokens, end_tokens, until_tokens, while_tokens)

    @step = ValueExpressionSet.new(step_tokens, :scalar)
    @end = ValueExpressionSet.new(end_tokens, :scalar)

    @errors << 'TAB() not allowed' if @step.has_tab
    @errors << 'TAB() not allowed' if @end.has_tab

    @numerics += @end.numerics
    @strings += @end.strings
    @booleans += @end.booleans
    @variables += @end.variables
    @operators += @end.operators
    @functions += @end.functions
    @userfuncs += @end.userfuncs

    @numerics += @step.numerics
    @strings += @step.strings
    @booleans += @step.booleans
    @variables += @step.variables
    @operators += @step.operators
    @functions += @step.functions
    @userfuncs += @step.userfuncs

    @pre_comp_effort =
      @end.comprehension_effort + @step.comprehension_effort

    @post_comp_effort = 1
  end

  def uncache
    @start.uncache
    @end.uncache
    @step.uncache
  end

  def dump
    lines = []
    lines << ("control: #{@control_variable.dump}")
    lines << ("start:   #{@start.dump}")
    lines << ("end:     #{@end.dump}")
    lines << ("step:    #{@step.dump}")
    lines
  end

  def pre_pretty
    "FOR #{@control_variable} = #{@start} TO #{@end} STEP #{@step}"
  end
end

class ForStepToModifier < AbstractForModifier
  def initialize(tokens_lists, control_and_start_tokens, step_tokens, end_tokens)
    until_tokens = nil
    while_tokens = nil

    super(tokens_lists, control_and_start_tokens, step_tokens, end_tokens, until_tokens, while_tokens)

    @step = ValueExpressionSet.new(step_tokens, :scalar)
    @end = ValueExpressionSet.new(end_tokens, :scalar)

    @errors << 'TAB() not allowed' if @step.has_tab
    @errors << 'TAB() not allowed' if @end.has_tab

    @numerics += @end.numerics
    @strings += @end.strings
    @booleans += @end.booleans
    @variables += @end.variables
    @operators += @end.operators
    @functions += @end.functions
    @userfuncs += @end.userfuncs

    @numerics += @step.numerics
    @strings += @step.strings
    @booleans += @step.booleans
    @variables += @step.variables
    @operators += @step.operators
    @functions += @step.functions
    @userfuncs += @step.userfuncs

    @pre_comp_effort =
      @end.comprehension_effort + @step.comprehension_effort

    @post_comp_effort = 1
  end

  def uncache
    @start.uncache
    @end.uncache
    @step.uncache
  end

  def dump
    lines = []
    lines << ("control: #{@control_variable.dump}")
    lines << ("start:   #{@start.dump}")
    lines << ("end:     #{@end.dump}")
    lines << ("step:    #{@step.dump}")
    lines
  end

  def pre_pretty
    "FOR #{@control_variable} = #{@start} TO #{@end} STEP #{@step}"
  end
end

class ForUntilModifier < AbstractForModifier
  def initialize(tokens_lists, control_and_start_tokens, until_tokens)
    step_tokens = nil
    end_tokens = nil
    while_tokens = nil

    super(tokens_lists, control_and_start_tokens, step_tokens, end_tokens, until_tokens, while_tokens)

    @until = ValueExpressionSet.new(until_tokens, :scalar)
    @warnings << 'Constant expression' if @until.constant?

    @errors << 'TAB() not allowed' if @until.has_tab

    @numerics += @until.numerics
    @strings += @until.strings
    @booleans += @until.booleans
    @variables += @until.variables
    @operators += @until.operators
    @functions += @until.functions
    @userfuncs += @until.userfuncs

    @pre_comp_effort = @until.comprehension_effort
    @post_comp_effort = 1
  end

  def uncache
    @start.uncache
    @until.uncache
  end

  def dump
    lines = []
    lines << ("control: #{@control_variable.dump}")
    lines << ("start:   #{@start.dump}")
    lines << ("until:   #{@until.dump}")
    lines
  end

  def pre_pretty
    "FOR #{@control_variable} = #{@start} UNTIL #{@until}"
  end
end

class ForUntilStepModifier < AbstractForModifier
  def initialize(tokens_lists, control_and_start_tokens, step_tokens, until_tokens)
    end_tokens = nil
    while_tokens = nil

    super(tokens_lists, control_and_start_tokens, step_tokens, end_tokens, until_tokens, while_tokens)

    @step = ValueExpressionSet.new(step_tokens, :scalar)
    @until = ValueExpressionSet.new(until_tokens, :scalar)
    @warnings << 'Constant expression' if @until.constant?

    @errors << 'TAB() not allowed' if @step.has_tab
    @errors << 'TAB() not allowed' if @until.has_tab

    @numerics += @step.numerics
    @strings += @step.strings
    @booleans += @step.booleans
    @variables += @step.variables
    @operators += @step.operators
    @functions += @step.functions
    @userfuncs += @step.userfuncs

    @numerics += @until.numerics
    @strings += @until.strings
    @booleans += @until.booleans
    @variables += @until.variables
    @operators += @until.operators
    @functions += @until.functions
    @userfuncs += @until.userfuncs

    @pre_comp_effort =
      @step.comprehension_effort + @until.comprehension_effort

    @post_comp_effort = 1
  end

  def uncache
    @start.uncache
    @step.uncache
    @until.uncache
  end

  def dump
    lines = []
    lines << ("control: #{@control_variable.dump}")
    lines << ("start:   #{@start.dump}")
    lines << ("step:    #{@step.dump}")
    lines << ("until:   #{@until.dump}")
    lines
  end

  def pre_pretty
    "FOR #{@control_variable} = #{@start} UNTIL #{@until} STEP #{@step}"
  end
end

class ForStepUntilModifier < AbstractForModifier
  def initialize(tokens_lists, control_and_start_tokens, step_tokens, until_tokens)
    end_tokens = nil
    while_tokens = nil

    super(tokens_lists, control_and_start_tokens, step_tokens, end_tokens, until_tokens, while_tokens)

    @step = ValueExpressionSet.new(step_tokens, :scalar)
    @until = ValueExpressionSet.new(until_tokens, :scalar)
    @warnings << 'Constant expression' if @until.constant?

    @errors << 'TAB() not allowed' if @step.has_tab
    @errors << 'TAB() not allowed' if @until.has_tab

    @numerics += @step.numerics
    @strings += @step.strings
    @booleans += @step.booleans
    @variables += @step.variables
    @operators += @step.operators
    @functions += @step.functions
    @userfuncs += @step.userfuncs

    @numerics += @until.numerics
    @strings += @until.strings
    @booleans += @until.booleans
    @variables += @until.variables
    @operators += @until.operators
    @functions += @until.functions
    @userfuncs += @until.userfuncs

    @pre_comp_effort =
      @step.comprehension_effort + @until.comprehension_effort

    @post_comp_effort = 1
  end

  def uncache
    @start.uncache
    @step.uncache
    @until.uncache
  end

  def dump
    lines = []
    lines << ("control: #{@control_variable.dump}")
    lines << ("start:   #{@start.dump}")
    lines << ("step:    #{@step.dump}")
    lines << ("until:   #{@until.dump}")
    lines
  end

  def pre_pretty
    "FOR #{@control_variable} = #{@start} UNTIL #{@until} STEP #{@step}"
  end
end

class ForWhileModifier < AbstractForModifier
  def initialize(tokens_lists, control_and_start_tokens, while_tokens)
    step_tokens = nil
    end_tokens = nil
    until_tokens = nil

    super(tokens_lists, control_and_start_tokens, step_tokens, end_tokens, until_tokens, while_tokens)

    @while = ValueExpressionSet.new(while_tokens, :scalar)
    @warnings << 'Constant expression' if @while.constant?

    @errors << 'TAB() not allowed' if @while.has_tab

    @numerics += @while.numerics
    @strings += @while.strings
    @booleans += @while.booleans
    @variables += @while.variables
    @operators += @while.operators
    @functions += @while.functions
    @userfuncs += @while.userfuncs

    @pre_comp_effort = @while.comprehension_effort
    @post_comp_effort = 1
  end

  def uncache
    @start.uncache
    @while.uncache
  end

  def dump
    lines = []
    lines << ("control: #{@control_variable.dump}") unless
      @control_variable.nil?

    lines << ("start:   #{@start.dump}") unless @start.nil?
    lines << ("while:   #{@while.dump}") unless @while.nil?
    lines
  end

  def pre_pretty
    "FOR #{@control_variable} = #{@start} WHILE #{@while}"
  end
end

class ForWhileStepModifier < AbstractForModifier
  def initialize(tokens_lists, control_and_start_tokens, step_tokens, while_tokens)
    end_tokens = nil
    until_tokens = nil

    super(tokens_lists, control_and_start_tokens, step_tokens, end_tokens, until_tokens, while_tokens)

    @step = ValueExpressionSet.new(step_tokens, :scalar)
    @while = ValueExpressionSet.new(while_tokens, :scalar)
    @warnings << 'Constant expression' if @while.constant?

    @errors << 'TAB() not allowed' if @step.has_tab
    @errors << 'TAB() not allowed' if @while.has_tab

    @numerics += @step.numerics
    @strings += @step.strings
    @booleans += @step.booleans
    @variables += @step.variables
    @operators += @step.operators
    @functions += @step.functions
    @userfuncs += @step.userfuncs

    @numerics += @while.numerics
    @strings += @while.strings
    @booleans += @while.booleans
    @variables += @while.variables
    @operators += @while.operators
    @functions += @while.functions
    @userfuncs += @while.userfuncs

    @pre_comp_effort =
      @step.comprehension_effort + @while.comprehension_effort

    @post_comp_effort = 1
  end

  def uncache
    @start.uncache
    @step.uncache
    @while.uncache
  end

  def dump
    lines = []
    lines << ("control: #{@control_variable.dump}")
    lines << ("start:   #{@start.dump}")
    lines << ("step:    #{@step.dump}")
    lines << ("while:   #{@while.dump}")
    lines
  end

  def pre_pretty
    "FOR #{@control_variable} = #{@start} WHILE #{@while} STEP #{@step}"
  end
end

class ForStepWhileModifier < AbstractForModifier
  def initialize(tokens_lists, control_and_start_tokens, step_tokens, while_tokens)
    end_tokens = nil
    until_tokens = nil

    super(tokens_lists, control_and_start_tokens, step_tokens, end_tokens, until_tokens, while_tokens)

    @step = ValueExpressionSet.new(step_tokens, :scalar)
    @while = ValueExpressionSet.new(while_tokens, :scalar)
    @warnings << 'Constant expression' if @while.constant?

    @errors << 'TAB() not allowed' if @step.has_tab
    @errors << 'TAB() not allowed' if @while.has_tab

    @numerics += @step.numerics
    @strings += @step.strings
    @booleans += @step.booleans
    @variables += @step.variables
    @operators += @step.operators
    @functions += @step.functions
    @userfuncs += @step.userfuncs

    @numerics += @while.numerics
    @strings += @while.strings
    @booleans += @while.booleans
    @variables += @while.variables
    @operators += @while.operators
    @functions += @while.functions
    @userfuncs += @while.userfuncs

    @pre_comp_effort =
      @step.comprehension_effort + @while.comprehension_effort

    @post_comp_effort = 1
  end

  def uncache
    @start.uncache
    @step.uncache
    @while.uncache
  end

  def dump
    lines = []
    lines << ("control: #{@control_variable.dump}")
    lines << ("start:   #{@start.dump}")
    lines << ("step:    #{@step.dump}")
    lines << ("while:   #{@while.dump}")
    lines
  end

  def pre_pretty
    "FOR #{@control_variable} = #{@start} WHILE #{@while} STEP #{@step}"
  end
end
