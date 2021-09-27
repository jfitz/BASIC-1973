# Statement factory class
class StatementFactory
  include Singleton

  attr_writer :tokenbuilders

  def initialize
    @statement_definitions = statement_definitions
    @tokenbuilders = []
  end

  def parse(text)
    line_number = nil
    line = nil
    m = /\A\d+/.match(text)

    unless m.nil?
      token = NumericConstantToken.new(m[0])
      number = IntegerConstant.new(token)
      line_number = LineNumber.new(number)
      line_text = m.post_match
      all_tokens = tokenize(line_text)
      all_tokens.delete_if(&:break?)
      all_tokens.delete_if(&:whitespace?)
      comment = nil

      comment = all_tokens.pop if
        !all_tokens.empty? && all_tokens[-1].comment?

      line = create(line_number, line_text, all_tokens, comment)
    end

    [line_number, line]
  end

  def create(line_number, text, all_tokens, comment)
    statements = []
    statements_tokens = split_on_statement_separators(all_tokens)

    if statements_tokens.empty?
      statement = EmptyStatement.new(line_number)
      statements << statement
    else
      statement_index = 0
      statements_tokens.each do |statement_tokens|
        statement = UnknownStatement.new(line_number, text)

        begin
          statement = create_statement(line_number, text, statement_tokens)
        rescue BASICExpressionError, BASICRuntimeError => e
          statement = InvalidStatement.new(line_number, text, all_tokens, e)
        end

        statements << statement
        statement_index += 1
      end
    end

    Line.new(text, statements, all_tokens, comment)
  end

  def create_statement(line_number, text, statement_tokens)
    if statement_tokens.empty?
      statement = EmptyStatement.new(line_number)
    else
      statement = nil

      keywords, tokens = extract_keywords(statement_tokens)

      while statement.nil?
        if @statement_definitions.key?(keywords)
          tokens_lists = split_keywords(tokens)

          statement_definition = @statement_definitions[keywords]

          statement =
            statement_definition.new(line_number, keywords, tokens_lists)
        else
          if keywords.empty?
            statement = UnknownStatement.new(line_number, text) if statement.nil?
          else
            keyword = keywords.pop
            tokens.unshift(keyword)
          end
        end
      end
    end

    statement
  end

  def keywords_definitions
    keywords = []

    statement_classes.each do |cl|
      kwds = cl.lead_keywords.flatten
      kwds.each { |kwd| keywords << kwd.to_s }

      keywords += cl.extra_keywords
    end

    modifier_classes.each do |cl|
      kwds = cl.lead_keywords.flatten
      kwds.each { |kwd| keywords << kwd.to_s }

      keywords += cl.extra_keywords
    end

    keywords.uniq
  end

  private

  def statement_classes
    [
      ArrForgetStatement,
      ArrInputStatement,
      ArrPlotStatement,
      ArrPrintStatement,
      ArrReadStatement,
      ArrWriteStatement,
      ArrLetStatement,
      ChainStatement,
      ChangeStatement,
      CloseStatement,
      DataStatement,
      DefineFunctionStatement,
      DimStatement,
      EndStatement,
      FilesStatement,
      FnendStatement,
      ForgetStatement,
      ForStatement,
      GetStatement,
      GosubStatement,
      GotoStatement,
      IfStatement,
      InputStatement,
      InputCharStatement,
      LetStatement,
      LetLessStatement,
      LineInputStatement,
      MatForgetStatement,
      MatInputStatement,
      MatPlotStatement,
      MatPrintStatement,
      MatReadStatement,
      MatWriteStatement,
      MatLetStatement,
      NextStatement,
      OnStatement,
      OnErrorStatement,
      OpenStatement,
      OptionStatement,
      PrintStatement,
      PutStatement,
      RandomizeStatement,
      ReadStatement,
      RecordStatement,
      RemarkStatement,
      RestoreStatement,
      ResumeStatement,
      ReturnStatement,
      RunStatement,
      SleepStatement,
      StopStatement,
      UnsaveStatement,
      WriteStatement
    ]
  end

  def modifier_classes
    [
      IfModifier,
      UnlessModifier,
      WhileModifier,
      UntilModifier,
      ForToModifier,
      ForToStepModifier,
      ForStepToModifier,
      ForUntilModifier,
      ForUntilStepModifier,
      ForStepUntilModifier,
      ForWhileModifier,
      ForWhileStepModifier,
      ForStepWhileModifier
    ]
  end

  def statement_definitions
    lead_keywords = {}

    statement_classes.each do |class_name|
      keyword_sets = class_name.lead_keywords

      keyword_sets.each do |set|
        lead_keywords[set] = class_name
      end
    end

    lead_keywords
  end

  def split_on_statement_separators(tokens)
    tokens_lists = []
    statement_tokens = []

    tokens.each do |token|
      if token.statement_separator?
        tokens_lists << statement_tokens
        statement_tokens = []
      else
        statement_tokens << token
      end
    end

    tokens_lists << statement_tokens unless statement_tokens.empty?
    tokens_lists
  end

  def extract_keywords(all_tokens)
    keywords = []
    tokens = []
    saw_non_keyword = false

    all_tokens.each do |token|
      saw_non_keyword = true unless token.keyword?
      keywords << token unless saw_non_keyword
      tokens << token if saw_non_keyword
    end

    [keywords, tokens]
  end

  def split_keywords(tokens)
    results = []
    nonkeywords = []

    tokens.each do |token|
      if token.keyword?
        results << nonkeywords unless nonkeywords.empty?
        nonkeywords = []
        results << token
      else
        nonkeywords << token
      end
    end

    results << nonkeywords unless nonkeywords.empty?

    results
  end

  def tokenize(text)
    invalid_tokenbuilder = InvalidTokenBuilder.new
    tokenizer = Tokenizer.new(@tokenbuilders, invalid_tokenbuilder)
    tokenizer.tokenize(text)
  end
end

# parent of all statement classes
class AbstractStatement
  attr_reader :errors
  attr_reader :warnings
  attr_reader :keywords
  attr_reader :tokens
  attr_reader :separators
  attr_accessor :part_of_user_function
  attr_reader :valid
  attr_reader :executable
  attr_reader :comment
  attr_reader :linenums
  attr_reader :autonext
  attr_reader :is_if_no_else
  attr_reader :may_be_if_sub

  def self.extra_keywords
    []
  end

  def initialize(_, keywords, tokens_lists)
    @keywords = keywords
    @executable = true
    @tokens = tokens_lists.flatten
    @core_tokens = tokens_lists.flatten
    @separators = get_separators(@core_tokens)
    @errors = []
    @warnings = []
    @valid = true
    @comment = false
    @modifiers = []
    @any_if_modifiers = false
    @elements = {
      numerics: [],
      num_symbols: [],
      strings: [],
      booleans: [],
      text_symbols: [],
      variables: [],
      operators: [],
      functions: [],
      userfuncs: []
    }
    @linenums = []
    @autonext = true
    @comprehension_effort = 1
    @mccabe = 0
    @is_if_no_else = false
    @may_be_if_sub = true
    @profile_count = 0
    @profile_time = 0
    @part_of_user_function = nil
  end

  private

  def extract_modifiers(tokens_lists)
    while make_modifier(tokens_lists); end
    @core_tokens = tokens_lists.flatten

    @modifiers.each do |modifier|
      @errors += modifier.errors
      @warnings += modifier.warnings
    end
  end

  public

  def uncache
    uncache_core

    @modifiers.each(&:uncache)
  end

  def uncache_core; end

  def pretty
    AbstractToken.pretty_tokens(@keywords, @tokens)
  end

  def core_pretty
    AbstractToken.pretty_tokens(@keywords, @core_tokens)
  end

  def analyze_pretty(number)
    texts = []

    text = ''

    text += "#{@part_of_user_function} " unless @part_of_user_function.nil?

    text += "(#{@mccabe} #{@comprehension_effort}) #{number} #{core_pretty}"

    texts << text

    number = ' ' * number.size

    @modifiers.each do |modifier|
      texts << modifier.pre_analyze(number)
      texts << modifier.post_analyze(number)
    end

    texts
  end

  def comprehension_effort
    result = @comprehension_effort

    @modifiers.each do |modifier|
      result += modifier.pre_comp_effort + modifier.post_comp_effort
    end

    result
  end

  def mccabe
    result = @mccabe
    @modifiers.each { |modifier| result += modifier.mccabe }
    result
  end

  def pre_trace(index)
    index = -index
    index -= 1
    @modifiers[index].pre_trace
  end

  def core_trace
    AbstractToken.pretty_tokens(@keywords, @core_tokens)
  end

  def post_trace(index)
    index -= 1
    @modifiers[index].post_trace
  end

  def dump
    ['Unimplemented']
  end

  def text_symbol_constants
    syms = @tokens.clone
    syms.keep_if(&:symbol_constant?)
    syms.keep_if(&:text_constant?)
  end

  def numerics
    @elements[:numerics]
  end

  def num_symbols
    @elements[:num_symbols]
  end

  def strings
    @elements[:strings]
  end

  def booleans
    @elements[:booleans]
  end

  def text_symbols
    @elements[:text_symbols]
  end

  def variables
    @elements[:variables]
  end

  def operators
    @elements[:operators]
  end

  def functions
    @elements[:functions]
  end

  def userfuncs
    @elements[:userfuncs]
  end

  def modifier_numerics
    nums = []
    @modifiers.each { |modifier| nums += modifier.numerics }
    nums
  end

  def modifier_num_symbols
    syms = []
    syms
  end

  def numeric_symbol_constants
    syms = @tokens.clone
    syms.keep_if(&:symbol_constant?)
    syms.keep_if(&:numeric_constant?)
  end

  def modifier_strings
    strs = []
    @modifiers.each { |modifier| strs += modifier.strings }
    strs
  end

  def modifier_booleans
    bools = []
    @modifiers.each { |modifier| bools += modifier.booleans }
    bools
  end

  def modifier_text_symbols
    syms = []
    syms
  end

  def modifier_variables
    vars = []
    @modifiers.each { |modifier| vars += modifier.variables }
    vars
  end

  def modifier_operators
    opers = []
    @modifiers.each { |modifier| opers += modifier.operators }
    opers
  end

  def modifier_functions
    vars = []
    @modifiers.each { |modifier| vars += modifier.functions }
    vars
  end

  def modifier_userfuncs
    vars = []
    @modifiers.each { |modifier| vars += modifier.userfuncs }
    vars
  end

  def gotos(_)
    []
  end

  def print_errors(console_io)
    @errors.each { |error| console_io.print_line(' ' + error) }
  end

  def okay(_, _, _)
    true
  end

  def check_for_errors(line_number, interpreter, console_io)
    unless errors.empty?
      interpreter.stop_running
      console_io.print_line("Errors in line #{line_number}:")
      print_errors(console_io)
    end

    errors.empty?
  end

  def optimize(interpreter, line_stmt_mod, program)
    set_for_lines(interpreter, line_stmt_mod, program)
    define_user_functions(interpreter)

    line_number = line_stmt_mod.line_number
    stmt = line_stmt_mod.statement

    @modifiers.each_with_index do |modifier, index|
      mod = index + 1
      mod_line_stmt_mod = LineStmtMod.new(line_number, stmt, mod)
      modifier.optimize(interpreter, mod_line_stmt_mod, program)
    end
  end

  def init_data(interpreter)
    load_data(interpreter)
    load_file_names(interpreter)
  end

  def number_for_stmts
    0
  end

  def set_for_lines (_, _, _) end

  private

  def get_separators(tokens)
    wanted = ['(', ')', '[', ']', ',', ';']

    separators = []

    tokens.each do |token|
      separators << token if wanted.include?(token.to_s)
    end

    separators
  end

  def define_user_functions(_) end

  def load_data(_) end

  def load_file_names(_) end

  public

  def reset_profile_metrics
    @profile_count = 0
    @profile_time = 0

    @modifiers.each { |modifier| modifier.reset_profile_metrics }
  end

  def profile(show_timing)
    # core statement
    text = AbstractToken.pretty_tokens(@keywords, @core_tokens)
    text = ' ' + text unless text.empty?

    line = ''

    line = " #{@part_of_user_function}" unless @part_of_user_function.nil?

    if show_timing
      line += " (#{@profile_time.round(4)}/#{@profile_count})"
    else
      line += " (#{@profile_count})"
    end

    line += text

    lines = [line]

    # modifiers
    @modifiers.each do |modifier|
      # first the pre line
      text = modifier.pre_pretty

      if show_timing
        timing = modifier.profile_pre_time.round(3).to_s
        line = ' (' + timing + '/' + modifier.profile_pre_count.to_s + ')' + text
        lines << line
      else
        line = ' (' + modifier.profile_pre_count.to_s + ')' + text
        lines << line
      end

      # then the post line
      text = modifier.post_pretty

      if show_timing
        timing = modifier.profile_post_time.round(3).to_s
        line = ' (' + timing + '/' + modifier.profile_post_count.to_s + ')' + text
        lines << line
      else
        line = ' (' + modifier.profile_post_count.to_s + ')' + text
        lines << line
      end
    end

    lines
  end

  def renumber(_) end

  private

  def execute(interpreter)
    current_line_stmt_mod = interpreter.current_line_stmt_mod
    index = current_line_stmt_mod.index

    if index < 0
      execute_premodifier(interpreter)
    end

    if index.zero?
      timing = Benchmark.measure { execute_core(interpreter) }

      user_time = timing.utime + timing.cutime
      sys_time = timing.stime + timing.cstime
      time = user_time + sys_time

      @profile_time += time
      @profile_count += 1
    end

    if index > 0
      execute_postmodifier(interpreter)
    end
  end

  public

  def print_trace_info(trace_out, current_line_stmt_mod)
    trace_out.newline_when_needed

    trace_out.print_out "#{@part_of_user_function} " unless
      @part_of_user_function.nil?

    index = current_line_stmt_mod.index

    text = ''

    text = pre_trace(index) if index < 0
    text = core_trace if index.zero?
    text = post_trace(index) if index > 0

    text = ' ' + text unless text.empty?
    text = current_line_stmt_mod.to_s + ':' + text

    trace_out.print_out(text)
    trace_out.newline
  end

  def execute_a_statement(interpreter, current_line_stmt_mod)
    current_user_function = interpreter.current_user_function

    if @part_of_user_function != current_user_function
      raise(BASICSyntaxError, 'Invalid transfer in/out of function')
    end

    execute(interpreter)
  end

  def start_index
    0 - @modifiers.size
  end

  def last_index
    @modifiers.size
  end

  def singledef?
    false
  end

  def multidef?
    false
  end

  def multiend?
    false
  end

  private

  def make_modifier(tokens_lists)
    template_if = ['IF', [1, '>=']]

    if tokens_lists.size > 1 &&
       check_template(tokens_lists.last(2), template_if)

      # create the modifier
      modifier_tokens = tokens_lists.last(2)
      modifier = IfModifier.new(modifier_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(2)

      @any_if_modifiers = true

      return true
    end

    template_unless = ['UNLESS', [1, '>=']]

    if tokens_lists.size > 1 &&
       check_template(tokens_lists.last(2), template_unless)

      # create the modifier
      modifier_tokens = tokens_lists.last(2)
      modifier = UnlessModifier.new(modifier_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(2)

      # any_if because its a conditional
      @any_if_modifiers = true

      return true
    end

    template_for_to = ['FOR', [1, '>='], 'TO', [1, '>=']]
    template_for_to_step = ['FOR', [1, '>='], 'TO', [1, '='], 'STEP', [1, '>=']]
    template_for_step_to = ['FOR', [1, '>='], 'STEP', [1, '>='], 'TO', [1, '=']]
    template_for_until = ['FOR', [1, '>='], 'UNTIL', [1, '>=']]
    template_for_until_step = ['FOR', [1, '>='], 'UNTIL', [1, '>='], 'STEP', [1, '>=']]
    template_for_step_until = ['FOR', [1, '>='], 'STEP', [1, '>='], 'UNTIL', [1, '>=']]
    template_for_while = ['FOR', [1, '>='], 'WHILE', [1, '>=']]
    template_for_while_step = ['FOR', [1, '>='], 'WHILE', [1, '>='], 'STEP', [1, '>=']]
    template_for_step_while = ['FOR', [1, '>='], 'STEP', [1, '>='], 'WHILE', [1, '>=']]

    if tokens_lists.size > 4 &&
       check_template(tokens_lists.last(4), template_for_to)

      # create the modifier
      expression_tokens = tokens_lists.last(4)
      control_and_start_tokens = tokens_lists[-3]
      end_tokens = tokens_lists.last

      modifier = ForToModifier.new(expression_tokens, control_and_start_tokens, end_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(4)

      return true
    end

    if tokens_lists.size > 6 &&
       check_template(tokens_lists.last(6), template_for_to_step)

      # create the modifier
      expression_tokens = tokens_lists.last(6)
      control_and_start_tokens = tokens_lists[-5]
      end_tokens = tokens_lists[-3]
      step_tokens = tokens_lists.last

      modifier =
        ForToStepModifier.new(expression_tokens, control_and_start_tokens, step_tokens, end_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(6)

      return true
    end

    if tokens_lists.size > 6 &&
       check_template(tokens_lists.last(6), template_for_step_to)

      # create the modifier
      expression_tokens = tokens_lists.last(6)
      control_and_start_tokens = tokens_lists[-5]
      end_tokens = tokens_lists.last
      step_tokens = tokens_lists[-3]

      modifier =
        ForStepToModifier.new(expression_tokens, control_and_start_tokens, step_tokens, end_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(6)

      return true
    end

    if tokens_lists.size > 4 &&
       check_template(tokens_lists.last(4), template_for_until)

      # create the modifier
      expression_tokens = tokens_lists.last(4)
      control_and_start_tokens = tokens_lists[-3]
      until_tokens = tokens_lists.last

      modifier = ForUntilModifier.new(expression_tokens, control_and_start_tokens, until_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(4)

      return true
    end

    if tokens_lists.size > 6 &&
       check_template(tokens_lists.last(6), template_for_until_step)

      # create the modifier
      expression_tokens = tokens_lists.last(6)
      control_and_start_tokens = tokens_lists[-5]
      until_tokens = tokens_lists[-3]
      step_tokens = tokens_lists.last

      modifier =
        ForUntilStepModifier.new(expression_tokens, control_and_start_tokens, step_tokens, until_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(6)

      return true
    end

    if tokens_lists.size > 6 &&
       check_template(tokens_lists.last(6), template_for_step_until)

      # create the modifier
      expression_tokens = tokens_lists.last(6)
      control_and_start_tokens = tokens_lists[-5]
      until_tokens = tokens_lists.last
      step_tokens = tokens_lists[-3]

      modifier =
        ForStepUntilModifier.new(expression_tokens, control_and_start_tokens, step_tokens, until_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(6)

      return true
    end

    if tokens_lists.size > 4 &&
       check_template(tokens_lists.last(4), template_for_while)

      # create the modifier
      expression_tokens = tokens_lists.last(4)
      control_and_start_tokens = tokens_lists[-3]
      while_tokens = tokens_lists.last

      modifier = ForWhileModifier.new(expression_tokens, control_and_start_tokens, while_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(4)

      return true
    end

    if tokens_lists.size > 6 &&
       check_template(tokens_lists.last(6), template_for_while_step)

      # create the modifier
      expression_tokens = tokens_lists.last(6)
      control_and_start_tokens = tokens_lists[-5]
      while_tokens = tokens_lists[-3]
      step_tokens = tokens_lists.last

      modifier =
        ForWhileStepModifier.new(expression_tokens, control_and_start_tokens, step_tokens, while_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(6)

      return true
    end

    if tokens_lists.size > 6 &&
       check_template(tokens_lists.last(6), template_for_step_while)

      # create the modifier
      expression_tokens = tokens_lists.last(6)
      control_and_start_tokens = tokens_lists[-5]
      while_tokens = tokens_lists.last
      step_tokens = tokens_lists[-3]

      modifier =
        ForStepWhileModifier.new(expression_tokens, control_and_start_tokens, step_tokens, while_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(6)

      return true
    end

    # WHILE modifier must follow FOR-WHILE
    template_unless = ['WHILE', [1, '>=']]

    if tokens_lists.size > 1 &&
       check_template(tokens_lists.last(2), template_unless)

      # create the modifier
      modifier_tokens = tokens_lists.last(2)
      modifier = WhileModifier.new(modifier_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(2)

      # any_if because its a conditional
      @any_if_modifiers = true

      return true
    end

    # UNTIL modifier must follow FOR-UNTIL
    template_unless = ['UNTIL', [1, '>=']]

    if tokens_lists.size > 1 &&
       check_template(tokens_lists.last(2), template_unless)

      # create the modifier
      modifier_tokens = tokens_lists.last(2)
      modifier = UntilModifier.new(modifier_tokens)
      @modifiers.unshift(modifier)

      # remove the tokens used for the modifier
      tokens_lists.pop(2)

      # any_if because its a conditional
      @any_if_modifiers = true

      return true
    end

    false
  end

  def execute_premodifier(interpreter)
    current_line_stmt_mod = interpreter.current_line_stmt_mod
    index = 0 - (current_line_stmt_mod.index + 1)
    modifier = @modifiers[index]
    modifier.execute_pre(interpreter)
  end

  def execute_postmodifier(interpreter)
    current_line_stmt_mod = interpreter.current_line_stmt_mod
    index = current_line_stmt_mod.index - 1
    modifier = @modifiers[index]
    modifier.execute_post(interpreter)
  end

  protected

  def check_template(tokens_lists, template)
    return false unless tokens_lists.size == template.size

    result = true
    pairs = template.zip(tokens_lists)

    pairs.each do |pair|
      control = pair[0]
      value = pair[1]

      if control.class.to_s == 'Array' &&
         value.class.to_s == 'Array'

        # control array and value array implies an expression
        result &= value.size == control[0] if control.size == 1

        result &= value.size >= control[0] if
          control.size == 2 && control[1] == '>='

      elsif control.class.to_s == 'Array' &&
            value.class.to_s == 'KeywordToken'

        # control array and single value (not array of one) implies
        # multiple possible keywords
        result &= control.include?(value.to_s)

      elsif control.class.to_s == 'String' &&
            value.class.to_s == 'KeywordToken'

        # single control and single value is a specific keyword
        result &= value.to_s == control

      else
        result = false
      end
    end

    result
  end

  def split_tokens(tokens, want_separators)
    lists = []
    list = []
    parens_level = 0

    tokens.each do |token|
      if token.operand? &&
         (!list.empty? && (list[-1].operand? || list[-1].group_end?))
        lists << list unless list.empty?
        list = [token]
      elsif token.separator? && parens_level.zero?
        lists << list unless list.empty?
        lists << token if want_separators
        list = []
      else
        list << token
      end

      parens_level += 1 if token.group_start?
      parens_level -= 1 if token.group_end? && !parens_level.zero?
    end

    lists << list unless list.empty?

    lists
  end

  def split_on_token(tokens, token_to_split)
    results = []
    list = []

    tokens.each do |token|
      if token.to_s != token_to_split
        list << token
      else
        results << list unless list.empty?
        list = []
        results << token
      end
    end

    results << list unless list.empty?

    results
  end

  def split_keywords(tokens)
    results = []
    nonkeywords = []

    tokens.each do |token|
      if token.keyword?
        results << nonkeywords unless nonkeywords.empty?
        nonkeywords = []
        results << token
      else
        nonkeywords << token
      end
    end

    results << nonkeywords unless nonkeywords.empty?

    results
  end

  def split_on_group_separators(tokens)
    tokens_lists = []
    statement_tokens = []

    # set to TRUE, so an empty list creates one empty token
    last_was_separator = true

    tokens.each do |token|
      if token.separator?
        tokens_lists << statement_tokens
        statement_tokens = []
        last_was_separator = true
      else
        statement_tokens << token
        last_was_separator = false
      end
    end

    tokens_lists << statement_tokens if
      !statement_tokens.empty? || last_was_separator
    tokens_lists
  end

  def make_references(items, exp1 = nil, exp2 = nil)
    numerics = []
    num_symbols = []
    strings = []
    booleans = []
    text_symbols = []
    variables = []
    operators = []
    functions = []
    userfuncs = []

    unless exp1.nil?
      numerics += exp1.numerics
      num_symbols += exp1.num_symbols
      strings += exp1.strings
      booleans += exp1.booleans
      text_symbols += exp1.text_symbols
      variables += exp1.variables
      operators += exp1.operators
      functions += exp1.functions
      userfuncs += exp1.userfuncs
    end

    unless exp2.nil?
      numerics += exp2.numerics
      num_symbols += exp2.num_symbols
      strings += exp2.strings
      booleans += exp2.booleans
      text_symbols += exp2.text_symbols
      variables += exp2.variables
      operators += exp2.operators
      functions += exp2.functions
      userfuncs += exp2.userfuncs
    end

    unless items.nil?
      items.each { |item| numerics += item.numerics }
      items.each { |item| num_symbols += item.num_symbols }
      items.each { |item| strings += item.strings }
      items.each { |item| booleans += item.booleans }
      items.each { |item| text_symbols += item.text_symbols }
      items.each { |item| variables += item.variables }
      items.each { |item| operators += item.operators }
      items.each { |item| functions += item.functions }
      items.each { |item| userfuncs += item.userfuncs }
    end

    {
      numerics: numerics,
      num_symbols: num_symbols,
      strings: strings,
      booleans: booleans,
      text_symbols: text_symbols,
      variables: variables,
      operators: operators,
      functions: functions,
      userfuncs: userfuncs
    }
  end
end

# unparsed statement
class InvalidStatement < AbstractStatement
  def initialize(line_number, text, all_tokens, error)
    super(line_number, [], all_tokens)

    @valid = false
    @executable = false
    @autonext = false
    @text = text
    @errors << 'Invalid statement: ' + error.message
  end

  def to_s
    @text
  end

  def set_for_lines(_, _, _)
    raise(BASICSyntaxError, @errors[0])
  end

  def define_user_functions(_)
    raise(BASICSyntaxError, @errors[0])
  end

  def load_data(_)
    raise(BASICSyntaxError, @errors[0])
  end

  def load_file_names(_)
    raise(BASICSyntaxError, @errors[0])
  end

  def execute_core(_)
    raise(BASICSyntaxError, @errors[0])
  end
end

# unknown statement
class UnknownStatement < AbstractStatement
  def initialize(line_number, text)
    super(line_number, [], [])

    @valid = false
    @executable = false
    @text = text
    @errors << "Unknown statement '#{text.strip}'"
  end

  def to_s
    @text
  end

  def execute_core(_) end
end

# empty statement (line number only)
class EmptyStatement < AbstractStatement
  def initialize(line_number)
    super(line_number, [], [])

    @valid = false
    @executable = false
    @comprehension_effort = 0
  end

  def dump
    []
  end

  def to_s
    ''
  end

  def execute_core(_) end
end

# REMARK
class RemarkStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('REMARK')],
      [KeywordToken.new('REM')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    @valid = false
    @comment = true
    @executable = false
    @rest = Remark.new(nil)
    @rest = Remark.new(tokens_lists[0]) unless tokens_lists.empty?
  end

  def dump
    lines = [@rest.dump]

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(_) end
end

# common functions for IO statements
module FileFunctions
  def extract_file_handle(items)
    file_tokens = nil

    unless items.empty? ||
           items[0].carriage_control?

      candidate_file_tokens = items[0]

      if candidate_file_tokens.filehandle?
        file_tokens = items.shift

        items.shift if
          !items.empty? &&
          items[0].carriage_control?
      end
    end

    file_tokens
  end

  def get_file_handle(interpreter, file_tokens)
    return nil if file_tokens.nil?

    file_handles = file_tokens.evaluate(interpreter)
    file_handles[0]
  end

  def add_needed_value(items, shape)
    items << ValueExpressionSet.new([], shape) if
      items.empty? || items[-1].carriage_control?
  end

  def add_needed_carriage(items)
    items << CarriageControl.new('') if
      !items.empty? && !items[-1].carriage_control?
  end

  def add_final_carriage(items, final)
    items << final if
      !items.empty? && !items[-1].carriage_control?
  end

  def add_default_value_carriage(items, shape)
    return unless items.empty?

    add_needed_value(items, shape)
    add_final_carriage(items, CarriageControl.new('NL'))
  end

  def dump
    lines = []

    lines += @file_tokens.dump unless @file_tokens.nil?
    @items.each { |item| lines += item.dump } unless @items.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end
end

# common functions for INPUT statements
module InputFunctions
  def extract_prompt(items)
    prompt = nil

    unless items.empty? ||
           items[0].carriage_control?

      candidate_prompt_tokens = items[0]

      if candidate_prompt_tokens.text_constant?
        prompt = items.shift

        items.shift if
          !items.empty? &&
          items[0].carriage_control?
      end
    end

    prompt
  end

  def tokens_to_expressions(tokens_lists, shape, set_dims)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape, set_dims)
      end
    end

    items
  end

  def add_expression(items, tokens, shape, set_dims)
    if tokens[0].operator? && tokens[0].pound?
      items << ValueExpressionSet.new(tokens, :scalar)
    elsif tokens[0].text_constant?
      items << ValueExpressionSet.new(tokens, :scalar)
    else
      items << TargetExpressionSet.new(tokens, shape, set_dims)
    end
  rescue BASICExpressionError => e
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" ' + e.to_s
  end

  def zip(names, values)
    raise BASICRuntimeError.new(:te_too_few) if values.size < names.size

    results = []
    (0...names.size).each do |i|
      results << { 'name' => names[i], 'value' => values[i] }
    end

    results
  end

  def input_values(fhr, interpreter, prompt, count)
    values = []

    while values.size < count
      remaining = count - values.size
      fhr.prompt(prompt, remaining)
      values += fhr.input(interpreter)

      prompt = nil
    end

    values
  end

  def uncache_core
    @items.each(&:uncache)
  end

  def file_values(fhr, interpreter)
    values = []

    values += fhr.input(interpreter)

    values
  end
end

# common functions for PRINT statements
module PrintFunctions
  def tokens_to_expressions(tokens_lists, shape)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape)
      elsif tokens_list.separator?
        add_needed_value(items, shape)
        items << CarriageControl.new(tokens_list.to_s)
      end
    end

    add_final_carriage(items, CarriageControl.new('NL'))
    add_default_value_carriage(items, shape)
    items
  end

  def tokens_to_expressions_2(tokens_lists, shape)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape)
      end
    end

    items
  end

  def add_expression(items, tokens, shape)
    if tokens[0].operator? && tokens[0].pound?
      items << ValueExpressionSet.new(tokens, :scalar)
    else
      add_needed_carriage(items)
      items << ValueExpressionSet.new(tokens, shape)
    end
  rescue BASICExpressionError => e
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" ' + e.to_s
  end

  def uncache_core
    @items.each do |item|
      item.each(&:uncache) if item.class.to_s == 'Array'
    end
  end

  def extract_format(items, interpreter)
    items = items.clone
    format = nil

    unless items.empty? ||
           items[0].class.to_s != 'ValueExpressionSet' &&
           items[-1].scalar?

      value = first_item(items, interpreter)

      if value.text_constant?
        format = value
        items.shift

        items.shift if
          !items.empty? &&
          items[0].carriage_control?
      end
    end

    [format, items]
  end

  def first_item(items, interpreter)
    first_list = items[0]
    values = first_list.evaluate(interpreter)

    values[0]
  end

  def split_format(format)
    format_text = format.to_v
    tokenbuilders = [
      ConstantFormatTokenBuilder.new,
      PaddedStringFormatTokenBuilder.new,
      PlainStringFormatTokenBuilder.new,
      CharFormatTokenBuilder.new,
      NumericFormatTokenBuilder.new
    ]
    tokenizer = Tokenizer.new(tokenbuilders, nil)
    tokenizer.tokenize(format_text)
  end

  def dump
    lines = []

    lines += @file_tokens.dump unless @file_tokens.nil?

    @items.each do |item|
      if item.class.to_s == 'Array'
        item.each { |it| lines += it.dump }
      elsif item.keyword?
        lines << 'Keyword:' + item.to_s
      end
    end

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end
end

# common functions for READ statements
module ReadFunctions
  def tokens_to_expressions(tokens_lists, shape, set_dims)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape, set_dims)
      end
    end

    items
  end

  def add_expression(items, tokens, shape, set_dims)
    if tokens[0].operator? && tokens[0].pound?
      items << ValueExpressionSet.new(tokens, :scalar)
    else
      items << TargetExpressionSet.new(tokens, shape, set_dims)
    end
  rescue BASICExpressionError => e
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" ' + e.to_s
  end

  def uncache_core
    @items.each(&:uncache)
  end
end

# common functions for WRITE statements
module WriteFunctions
  def tokens_to_expressions(tokens_lists, shape)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape)
      elsif tokens_list.separator?
        add_needed_value(items, shape)
        items << CarriageControl.new(tokens_list.to_s)
      end
    end

    add_final_carriage(items, CarriageControl.new('NL'))
    add_default_value_carriage(items, shape)
    items
  end

  def add_expression(items, tokens, shape)
    if tokens[0].operator? && tokens[0].pound?
      items << ValueExpressionSet.new(tokens, :scalar)
    else
      add_needed_carriage(items)
      items << ValueExpressionSet.new(tokens, shape)
    end
  rescue BASICExpressionError => e
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" ' + e.to_s
  end

  def uncache_core
    @items.each(&:uncache)
  end
end

# CHAIN
class ChainStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('CHAIN')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)
    @autonext = false unless @any_if_modifiers

    template = [[1, '>']]

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)

    target_tokens = tokens_lists[0]
    @target = ValueExpressionSet.new(target_tokens, :scalar)
    @errors << 'TAB() not allowed' if @target.has_tab

    @elements = make_references(nil, @target)
    @comprehension_effort += @target.comprehension_effort
  end

  def uncache_core
    @target.uncache
  end

  def dump
    lines = ['']

    lines += @target.dump

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    target_values = @target.evaluate(interpreter)
    target_value = target_values[0]

    raise(BASICExpressionError, 'Target must be text item.') unless
      target_value.text_constant?

    text = target_value.value

    # 'DEMON' is a special case
    if text.rstrip == 'DEMON'
      io = interpreter.console_io
      io.newline_when_needed
      interpreter.stop
    else
      interpreter.chain(target_values)
    end
  end
end

# CHANGE
class ChangeStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('CHANGE')],
      [KeywordToken.new('CHA')]
    ]
  end

  def self.extra_keywords
    ['TO']
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>='], 'TO', [1, '=']]

    if check_template(tokens_lists, template)
      source_tokens = tokens_lists[0]
      target_tokens = tokens_lists[2]

      source = ValueExpressionSet.new(source_tokens, :scalar)

      case source.content_type
      when :string
        # string to array
        @source = ValueExpressionSet.new(source_tokens, :scalar)
        @target = TargetExpressionSet.new(target_tokens, :array, false)
      when :numeric
        # array to string
        @source = ValueExpressionSet.new(source_tokens, :array)
        @target = TargetExpressionSet.new(target_tokens, :scalar, false)
      else
        raise BASICExpressionError, 'Type mismatch'
      end

      @errors << 'TAB() not allowed' if @target.has_tab
      @errors << 'TAB() not allowed' if @source.has_tab

      @elements = make_references(nil, @source, @target)
      @comprehension_effort += @source.comprehension_effort
      @comprehension_effort += @target.comprehension_effort
    else
      @errors << 'Syntax error'
    end
  end

  def uncache_core
    @source.uncache
    @target.uncache
  end

  def dump
    lines = []

    lines += @source.dump unless @source.nil?
    lines += @target.dump unless @target.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    source_values = @source.evaluate(interpreter)
    source_value = source_values[0]

    if source_value.text_constant?
      # string to array

      array = source_value.na_unpack
      dims = array.dimensions
      values = array.values_1

      target_token = VariableToken.new(@target.to_s)
      target_name = VariableName.new(target_token)
      target = Variable.new(target_name, :scalar, [], [])
      target.valref = :reference

      interpreter.set_dimensions(target, dims)
      interpreter.set_values(target_name, values)

    elsif source_value.numeric_constant?
      # array to string
      source_variable_token = VariableToken.new(@source.to_s)
      source_variable_name = VariableName.new(source_variable_token)

      target_values = @target.evaluate(interpreter)
      target = target_values[0]

      dims = interpreter.get_dimensions(source_variable_name)

      raise(BASICSyntaxError, 'Source not an array') if dims.nil?

      raise(BASICSyntaxError, 'Source must have 1 dimension') unless
        dims.size == 1

      cols = dims[0].to_i
      values = {}
      (0..cols).each do |col|
        column = IntegerConstant.new(col)
        variable = Variable.new(source_variable_name, :scalar, [column], [column])
        coord = AbstractElement.make_coord(col)
        values[coord] = interpreter.get_value(variable)
      end
      array = BASICArray.new(dims, values)
      text = array.pack

      interpreter.set_value(target, text)

    else
      raise BASICExpressionError, 'Type mismatch'
    end
  end
end

# CLOSE
class CloseStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('CLOSE')],
      [KeywordToken.new('CLO')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]
    template_file = ['FILE', [1, '>=']]

    @filenum_expression = []
    if check_template(tokens_lists, template) ||
       check_template(tokens_lists, template_file)
      @filenum_expression = ValueExpressionSet.new(tokens_lists[-1], :scalar)
      @errors << 'TAB() not allowed' if @filenum_expression.has_tab

      @elements = make_references(nil, @filenum_expression)
      @comprehension_effort += @filenum_expression.comprehension_effort
    else
      @errors << 'Syntax error'
    end
  end

  def uncache_core
    @filenum_expression.uncache
  end

  def dump
    lines = @filenum_expression.dump

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    fns = @filenum_expression.evaluate(interpreter)
    fh = FileHandle.new(fns[0])
    interpreter.close_file(fh)
  end
end

# DATA
class DataStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('DATA')],
      [KeywordToken.new('DAT')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    @executable = false
    @may_be_if_sub = false

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      @expressions = ValueExpressionSet.new(tokens_lists[0], :scalar)
      @errors << 'TAB() not allowed' if @expressions.has_tab

      @elements = make_references(nil, @expressions)
      @comprehension_effort += @expressions.comprehension_effort
    else
      @errors << 'Syntax error'
    end
  end

  def uncache_core
    @expressions.uncache unless @expressions.nil?
  end

  def dump
    lines = []

    lines += @expressions.dump unless @expressions.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def load_data(interpreter)
    ds = interpreter.get_data_store(nil)
    data_list = @expressions.evaluate(interpreter)
    ds.store(data_list)
  rescue BASICRuntimeError => e
    raise BASICPreexecuteError.new(e.scode, e.extra)
  end

  def execute_core(_) end
end

# DEF FNx
class DefineFunctionStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('DEF')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    @executable = false
    @may_be_if_sub = false

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      begin
        @definition = UserFunctionDefinition.new(tokens_lists[0])

        @elements = make_references(nil, @definition)
        @comprehension_effort += @definition.comprehension_effort
      rescue BASICExpressionError => e
        @errors << e.message
      end
    else
      @errors << 'Syntax error'
    end
  end

  def singledef?
    return false if @definition.nil?

    @definition.singledef?
  end

  def multidef?
    return false if @definition.nil?

    @definition.multidef?
  end

  def function_name
    @definition.name
  end

  def function_signature
    @definition.signature
  end

  def dump
    lines = []

    lines += @definition.dump unless @definition.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def define_user_functions(interpreter)
    unless @definition.nil?
      begin
        interpreter.set_user_function(@definition)
      rescue BASICRuntimeError => e
        raise BASICPreexecuteError.new(e.scode, e.extra)
      end
    end
  end

  def execute_core(_) end
end

# DIM
class DimStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('DIM')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    template = [[1, '>=']]

    @declarations = []
    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], false)

      tokens_lists.each do |tokens_list|
        begin
          @declarations << DeclarationExpressionSet.new(tokens_list)
        rescue BASICExpressionError => e
          @errors << 'Invalid ' + tokens_list.map(&:to_s).join + ' ' + e.to_s
        end
      end

      @elements = make_references(@declarations)

      @declarations.each do |expression|
        @comprehension_effort += expression.comprehension_effort
      end
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    @declarations.each { |expression| lines += expression.dump }

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    @declarations.each do |expression|
      variables = expression.evaluate(interpreter)
      variable = variables[0]
      subscripts = variable.subscripts

      if subscripts.empty?
        raise BASICSyntaxError, 'DIM statement requires subscript range'
      end

      interpreter.set_dimensions(variable, subscripts)
    end
  end
end

# END
class EndStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('END')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    @autonext = false
    @executable = false
    @may_be_if_sub = false

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def okay(program, console_io, line_number_index)
    next_line = program.find_next_line_stmt_mod(line_number_index)

    return true if next_line.nil?

    console_io.print_line("Statements after END in line #{line_number_index}")

    false
  end

  def execute_core(interpreter)
    io = interpreter.console_io
    io.newline_when_needed
    interpreter.stop
  end
end

# FILES
class FilesStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('FILES')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    @executable = false
    @may_be_if_sub = false

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      @expressions = ValueExpressionSet.new(tokens_lists[0], :scalar)
      @errors << 'TAB() not allowed' if @expressions.has_tab
      @elements = make_references(nil, @expressions)
      @comprehension_effort += @expressions.comprehension_effort
    else
      @errors << 'Syntax error'
    end
  end

  def uncache_core
    @expressions.uncache
  end

  def dump
    @expressions.dump unless @expressions.nil?
  end

  def load_file_names(interpreter)
    file_names = @expressions.evaluate(interpreter)
    interpreter.add_file_names(file_names)
  rescue BASICRuntimeError => e
    raise BASICPreexecuteError.new(e.scode, e.extra)
  end

  def execute_core(_) end
end

# FNEND
class FnendStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('FNEND')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    @may_be_if_sub = false

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def multiend?
    true
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    interpreter.exit_user_function
  end
end

# FOR statement
class ForStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('FOR')]
    ]
  end

  def self.extra_keywords
    %w[TO STEP UNTIL WHILE]
  end

  def initialize(_, keywords, tokens_lists)
    super

    @autonext = false
    @may_be_if_sub = false

    template_to = [[1, '>='], 'TO', [1, '>=']]
    template_to_step = [[1, '>='], 'TO', [1, '>='], 'STEP', [1, '>=']]
    template_step_to = [[1, '>='], 'STEP', [1, '>='], 'TO', [1, '>=']]
    template_until = [[1, '>='], 'UNTIL', [1, '>=']]
    template_until_step = [[1, '>='], 'UNTIL', [1, '>='], 'STEP', [1, '>=']]
    template_step_until = [[1, '>='], 'STEP', [1, '>='], 'UNTIL', [1, '>=']]
    template_while = [[1, '>='], 'WHILE', [1, '>=']]
    template_while_step = [[1, '>='], 'WHILE', [1, '>='], 'STEP', [1, '>=']]
    template_step_while = [[1, '>='], 'STEP', [1, '>='], 'WHILE', [1, '>=']]

    if check_template(tokens_lists, template_to)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        variable_name = VariableName.new(tokens1[0])
        @control = Variable.new(variable_name, :scalar, [], [])
        @start = ValueExpressionSet.new(tokens2, :scalar)
        @step = nil
        @end = ValueExpressionSet.new(tokens_lists[2], :scalar)
      rescue BASICExpressionError => e
        @errors << e.message
      end
    elsif check_template(tokens_lists, template_to_step)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        variable_name = VariableName.new(tokens1[0])
        @control = Variable.new(variable_name, :scalar, [], [])
        @start = ValueExpressionSet.new(tokens2, :scalar)
        @step = ValueExpressionSet.new(tokens_lists[4], :scalar)
        @end = ValueExpressionSet.new(tokens_lists[2], :scalar)
      rescue BASICExpressionError => e
        @errors << e.message
      end
    elsif check_template(tokens_lists, template_step_to)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        variable_name = VariableName.new(tokens1[0])
        @control = Variable.new(variable_name, :scalar, [], [])
        @start = ValueExpressionSet.new(tokens2, :scalar)
        @step = ValueExpressionSet.new(tokens_lists[2], :scalar)
        @end = ValueExpressionSet.new(tokens_lists[4], :scalar)
      rescue BASICExpressionError => e
        @errors << e.message
      end
    elsif check_template(tokens_lists, template_until)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        variable_name = VariableName.new(tokens1[0])
        @control = Variable.new(variable_name, :scalar, [], [])
        @start = ValueExpressionSet.new(tokens2, :scalar)
        @until = ValueExpressionSet.new(tokens_lists[2], :scalar)
      rescue BASICExpressionError => e
        @errors << e.message
      end
    elsif check_template(tokens_lists, template_until_step)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        variable_name = VariableName.new(tokens1[0])
        @control = Variable.new(variable_name, :scalar, [], [])
        @start = ValueExpressionSet.new(tokens2, :scalar)
        @until = ValueExpressionSet.new(tokens_lists[2], :scalar)
        @step = ValueExpressionSet.new(tokens_lists[4], :scalar)
      rescue BASICExpressionError => e
        @errors << e.message
      end
    elsif check_template(tokens_lists, template_step_until)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        variable_name = VariableName.new(tokens1[0])
        @control = Variable.new(variable_name, :scalar, [], [])
        @start = ValueExpressionSet.new(tokens2, :scalar)
        @step = ValueExpressionSet.new(tokens_lists[2], :scalar)
        @until = ValueExpressionSet.new(tokens_lists[4], :scalar)
      rescue BASICExpressionError => e
        @errors << e.message
      end
    elsif check_template(tokens_lists, template_while)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        variable_name = VariableName.new(tokens1[0])
        @control = Variable.new(variable_name, :scalar, [], [])
        @start = ValueExpressionSet.new(tokens2, :scalar)
        @while = ValueExpressionSet.new(tokens_lists[2], :scalar)
      rescue BASICExpressionError => e
        @errors << e.message
      end
    elsif check_template(tokens_lists, template_while_step)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        variable_name = VariableName.new(tokens1[0])
        @control = Variable.new(variable_name, :scalar, [], [])
        @start = ValueExpressionSet.new(tokens2, :scalar)
        @while = ValueExpressionSet.new(tokens_lists[2], :scalar)
        @step = ValueExpressionSet.new(tokens_lists[4], :scalar)
      rescue BASICExpressionError => e
        @errors << e.message
      end
    elsif check_template(tokens_lists, template_step_while)
      begin
        tokens1, tokens2 = control_and_start(tokens_lists[0])
        variable_name = VariableName.new(tokens1[0])
        @control = Variable.new(variable_name, :scalar, [], [])
        @start = ValueExpressionSet.new(tokens2, :scalar)
        @step = ValueExpressionSet.new(tokens_lists[2], :scalar)
        @while = ValueExpressionSet.new(tokens_lists[4], :scalar)
      rescue BASICExpressionError => e
        @errors << e.message
      end
    else
      @errors << 'Syntax error'
    end

    @errors << 'TAB() not allowed' if !@start.nil? && @start.has_tab
    @errors << 'TAB() not allowed' if !@step.nil? && @step.has_tab
    @errors << 'TAB() not allowed' if !@end.nil? && @end.has_tab
    @errors << 'TAB() not allowed' if !@while.nil? && @while.has_tab
    @errors << 'TAB() not allowed' if !@until.nil? && @until.has_tab

    @warnings << 'Constant expression' if !@until.nil? && @until.constant
    @warnings << 'Constant expression' if !@while.nil? && @while.constant

    @mccabe = 1

    control = XrefEntry.new(@control.to_s, nil, true)

    @elements[:numerics] = []
    @elements[:strings] = []
    @elements[:booleans] = []
    @elements[:variables] = []
    @elements[:operators] = []
    @elements[:functions] = []
    @elements[:userfuncs] = []

    unless @start.nil?
      @elements[:numerics] += @start.numerics
      @elements[:strings] += @start.strings
      @elements[:booleans] += @start.booleans
      @elements[:variables] += [control] + @start.variables
      @elements[:operators] += @start.operators
      @elements[:functions] += @start.functions
      @elements[:userfuncs] += @start.userfuncs
    end

    unless @end.nil?
      @elements[:numerics] += @end.numerics
      @elements[:strings] += @end.strings
      @elements[:booleans] += @end.booleans
      @elements[:variables] += @end.variables
      @elements[:operators] += @end.operators
      @elements[:functions] += @end.functions
      @elements[:userfuncs] += @end.userfuncs
    end

    unless @step.nil?
      @elements[:numerics] += @step.numerics
      @elements[:strings] += @step.strings
      @elements[:booleans] += @step.booleans
      @elements[:variables] += @step.variables
      @elements[:operators] += @step.operators
      @elements[:functions] += @step.functions
      @elements[:userfuncs] += @step.userfuncs
    end

    unless @until.nil?
      @elements[:numerics] += @until.numerics
      @elements[:strings] += @until.strings
      @elements[:booleans] += @until.booleans
      @elements[:variables] += @until.variables
      @elements[:operators] += @until.operators
      @elements[:functions] += @until.functions
      @elements[:userfuncs] += @until.userfuncs
    end

    unless @while.nil?
      @elements[:numerics] += @while.numerics
      @elements[:strings] += @while.strings
      @elements[:booleans] += @while.booleans
      @elements[:variables] += @while.variables
      @elements[:operators] += @while.operators
      @elements[:functions] += @while.functions
      @elements[:userfuncs] += @while.userfuncs
    end

    @comprehension_effort += @start.comprehension_effort unless @start.nil?
    @comprehension_effort += @end.comprehension_effort unless @end.nil?
    @comprehension_effort += @step.comprehension_effort unless @step.nil?
    @comprehension_effort += @until.comprehension_effort unless @until.nil?
    @comprehension_effort += @while.comprehension_effort unless @while.nil?
  end

  def uncache_core
    @start.uncache unless @start.nil?
    @end.uncache unless @end.nil?
    @step.uncache unless @step.nil?
    @until.uncache unless @until.nil?
    @while.uncache unless @while.nil?
  end

  def set_for_lines(interpreter, line_stmt_mod, program)
    @loopstart_line_stmt_mod = program.find_next_line_stmt_mod(line_stmt_mod)

    unless @control.nil?
      @nextstmt_line_stmt_mod =
        program.find_closing_next_line_stmt_mod(@control, line_stmt_mod)
    end
  end

  def dump
    lines = []

    lines << 'control: ' + @control.dump unless @control.nil?
    lines << 'start:   ' + @start.dump.to_s unless @start.nil?
    lines << 'end:     ' + @end.dump.to_s unless @end.nil?
    lines << 'step:    ' + @step.dump.to_s unless @step.nil?
    lines << 'until:   ' + @until.dump.to_s unless @until.nil?
    lines << 'while:   ' + @while.dump.to_s unless @while.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def gotos(_)
    goto_refs = []

    unless @loopstart_line_stmt_mod.nil?
      line_number = @loopstart_line_stmt_mod.line_number
      statement = @loopstart_line_stmt_mod.statement
      goto_refs << TransferRefLineStmt.new(line_number, statement, :fornext)
    end
    
    unless @nextstmt_line_stmt_mod.nil?
      line_number = @nextstmt_line_stmt_mod.line_number
      statement = @nextstmt_line_stmt_mod.statement
      goto_refs << TransferRefLineStmt.new(line_number, statement, :fornext)
    end
      
    goto_refs
  end

  def execute_core(interpreter)
    raise BASICSyntaxError.new("uninitialized FOR") if
      @loopstart_line_stmt_mod.nil?

    raise BASICSyntaxError.new("uninitialized FOR") if
      @nextstmt_line_stmt_mod.nil?

    from = @start.evaluate(interpreter)[0]
    step = NumericConstant.new(1)
    step = @step.evaluate(interpreter)[0] unless @step.nil?

    unless @end.nil?
      to = @end.evaluate(interpreter)[0]

      fornext_control =
        ForToControl.new(@control, from, step, to, @loopstart_line_stmt_mod)
    end

    unless @until.nil?
      fornext_control =
        ForUntilControl.new(@control, from, step, @until, @loopstart_line_stmt_mod)
    end

    unless @while.nil?
      fornext_control =
        ForWhileControl.new(@control, from, step, @while, @loopstart_line_stmt_mod)
    end

    interpreter.assign_fornext(fornext_control)

    interpreter.lock_variable(@control) if $options['lock_fornext'].value
    interpreter.enter_fornext(@control)

    terminated = fornext_control.front_terminated?(interpreter)

    if terminated
      interpreter.next_line_stmt_mod = @nextstmt_line_stmt_mod
    end

    untilv = nil
    untilv = @until.evaluate(interpreter)[0] unless @until.nil?
    whilev = nil
    whilev = @while.evaluate(interpreter)[0] unless @while.nil?
    io = interpreter.trace_out
    print_more_trace_info(io, from, to, step, untilv, whilev, terminated)
  end

  def number_for_stmts
    1
  end

  private

  def control_and_start(tokens)
    parts = split_on_token(tokens, '=')
    raise(BASICExpressionError, 'Incorrect initialization') if
      parts.size != 3
    raise(BASICExpressionError, 'Incorrect initialization') if
      parts[1].to_s != '='

    @errors << 'Control variable must be a variable' unless
      parts[0][0].variable?

    [parts[0], parts[2]]
  end

  def print_more_trace_info(io, from, to, step, untilv, whilev, terminated)
    io.trace_output(" #{@start} = #{from}") unless @start.numeric_constant?
    io.trace_output(" #{@end} = #{to}") unless
      @end.nil? || @end.numeric_constant?
    io.trace_output(" #{@step} = #{step}") unless
      @step.nil? || @step.numeric_constant?
    io.trace_output(" #{@until} = #{untilv}") unless @until.nil?
    io.trace_output(" #{@while} = #{whilev}") unless @while.nil?
    io.trace_output(" terminated:#{terminated}")
  end
end

# FORGET
class ForgetStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('FORGET')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      # parse variable(s)
      @variables = []

      tokens_list = split_on_group_separators(tokens_lists[0])
      tokens_list.each do |tokens|
        if tokens[0].variable?
          variable_name = VariableName.new(tokens[0])
          # FIX: parse subscripts
          variable = Variable.new(variable_name, :scalar, [], [])
          @variables << variable
          variablex = XrefEntry.new(variable.to_s, nil, false)
          @elements[:variables] += [variablex]
        else
          @errors << "Invalid variable #{tokens[0]}"
        end
      end
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    @variables.each { |variable| lines << variable.dump }

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    @variables.each { |variable| interpreter.forget_value(variable) }
  end
end

# GET
class GetStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('GET')]
    ]
  end

  include FileFunctions
  include InputFunctions

  def initialize(line_number, keywords, tokens_lists)
    super

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      if items.size == 3
        line_no = items[1]
        if line_no.empty?
          @errors << 'No line number'
        else
          token = line_no[0]
          begin
            number = IntegerConstant.new(token)
            @line_number = LineNumber.new(number)

            if @line_number > line_number
              @comprehension_effort += 2
            else
              @comprehension_effort += 1
            end
          rescue BASICSyntaxError => e
            @errors << e.message
          end
        end

        @items = tokens_to_expressions(items, :scalar)

        @items.each do |item|
          @errors << 'TAB() not allowed' if item.has_tab
        end

        @elements = make_references(@items)
        @items.each { |item| @comprehension_effort += item.comprehension_effort }
        @mccabe += @items.size
      else
        @errors << 'Syntax error'
      end
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []
    @items.each { |item| lines += item.dump }
    lines
  end

  def okay(program, console_io, line_number_index)
    retval = true

    unless program.line_number?(@line_number)
      console_io.print_line(
        "Line number #{@line_number} not found in line #{line_number_index}"
      )
      retval = false
    end

    retval
  end

  def execute_core(interpreter)
    file_no = @items[0]
    file_num = file_no.evaluate(interpreter)
    fh = FileHandle.new(file_num[0])
    fhr = interpreter.get_file_handler(fh, :memory)

    rec_no = @items[2]
    rec_num = rec_no.evaluate(interpreter)
    rec_number = rec_num[0].to_i

    read_items = interpreter.get_record_read_variables(@line_number)

    item_names = []
    read_items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        item_names << target
      end
    end

    # always from file, never from console
    values = fhr.read_record(interpreter, rec_number)

    raise BASICRuntimeError.new(:te_too_few) if values.size < item_names.size

    name_value_pairs =
      zip(item_names, values[0..item_names.length])

    name_value_pairs.each do |hash|
      variable = hash['name']
      value = hash['value']
      interpreter.set_value(variable, value)
    end

    interpreter.clear_previous_lines
  end

  def renumber(renumber_map)
    @line_number = renumber_map[@line_number]
    @token_index = -1
    i = 0
    num_commas = 1
    @tokens.each do |token|
      @token_index = i if token.numeric_constant? && num_commas == 1

      num_commas += 1 if token.separator?

      i += 1
    end
    @tokens[@token_index] = NumericConstantToken.new(@line_number.line_number)
  end

  private

  def tokens_to_expressions(tokens_lists, shape)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape)
      end
    end

    items
  end

  def add_expression(items, tokens, shape)
    items << ValueExpressionSet.new(tokens, shape)
  rescue BASICExpressionError
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" is not a value or operator'
  end
end

# GOSUB
class GosubStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('GOSUB')],
      [KeywordToken.new('GOS')]
    ]
  end

  def initialize(line_number, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1]]

    if check_template(tokens_lists, template)
      if tokens_lists[0][0].numeric_constant?
        number = IntegerConstant.new(tokens_lists[0][0])
        @destination = LineNumber.new(number)
        @linenums = [@destination]

        if @destination > line_number
          @comprehension_effort += 1
        else
          @comprehension_effort += 2
        end
      else
        @errors << "Invalid line number #{tokens_lists[0][0]}"
      end
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = [@destination.dump]

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def gotos(_)
    [TransferRefLineStmt.new(@destination, 0, :gosub)]
  end

  def okay(program, console_io, line_number_index)
    return true if program.line_number?(@destination)

    console_io.print_line(
      "Line number #{@destination} not found in line #{line_number_index}"
    )

    false
  end

  def execute_core(interpreter)
    line_number = @destination
    index = interpreter.statement_start_index(line_number, 0)

    raise(BASICSyntaxError, 'Line number not found') if index.nil?

    destination = LineStmtMod.new(line_number, 0, index)
    interpreter.push_return(interpreter.next_line_stmt_mod)
    interpreter.next_line_stmt_mod = destination
  end

  def renumber(renumber_map)
    @destination = renumber_map[@destination]
    @linenums = [@destination]
    @tokens[-1] = NumericConstantToken.new(@destination.line_number)
  end
end

# GOTO
class GotoStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('GOTO')],
      [KeywordToken.new('GOT')]
    ]
  end

  def self.extra_keywords
    ['OF']
  end

  def initialize(line_number, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)
    @autonext = false unless @any_if_modifiers

    template1 = [[1]]
    template2 = [[1, '>='], 'OF', [1, '>=']]
    @destination = nil
    @destinations = nil
    @expression = nil

    if check_template(tokens_lists, template1)
      if tokens_lists[0][0].numeric_constant?
        number = IntegerConstant.new(tokens_lists[0][0])
        @destination = LineNumber.new(number)
        @linenums = [@destination]

        if @destination > line_number
          @comprehension_effort += 1
        else
          @comprehension_effort += 2
        end
      else
        @errors << "Invalid line number #{tokens_lists[0][0]}"
      end
    elsif check_template(tokens_lists, template2)
      expression = tokens_lists[0]

      begin
        @expression = ValueExpressionSet.new(expression, :scalar)
      rescue BASICExpressionError => e
        @errors << e.message
      end

      @errors << 'TAB() not allowed' if
        !@expression.nil? && @expression.has_tab

      @warnings << 'Constant expression' if
        !@expression.nil? && @expression.constant

      @elements = make_references(nil, @expression)

      destinations = tokens_lists[2]
      line_nums = split_tokens(destinations, false)
      @destinations = []

      line_nums.each do |line_num|
        if line_num.size == 1
          token = line_num[0]
          if token.numeric_constant?
            number = IntegerConstant.new(token)
            @destinations << LineNumber.new(number)
          else
            @errors << "Invalid line number #{destination}"
          end
        else
          @errors << "Invalid line specification #{line_num}"
        end
      end

      @linenums = @destinations

      @comprehension_effort += @expression.comprehension_effort

      @destinations.each do |destination|
        if destination > line_number
          @comprehension_effort += 1
        else
          @comprehension_effort += 2
        end
      end
    else
      @errors << 'Syntax error'
    end
  end

  def uncache_core
    @expression.uncache unless @expression.nil?
  end

  def dump
    lines = []

    lines << @destination.dump unless @destination.nil?
    lines += @expression.dump unless @expression.nil?

    unless @destinations.nil?
      @destinations.each { |destination| lines << destination.dump }
    end

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def gotos(_)
    return [TransferRefLineStmt.new(@destination, 0, :goto)] unless
      @destination.nil?

    goto_refs = []

    @destinations.each do |goto|
      goto_refs << TransferRefLineStmt.new(goto, 0, :goto)
    end

    goto_refs
  end

  def okay(program, console_io, line_number_index)
    retval = true

    unless @destination.nil? || program.line_number?(@destination)
      console_io.print_line(
        "Line number #{@destination} not found in line #{line_number_index}"
      )
      retval = false
    end

    unless @destinations.nil?
      @destinations.each do |destination|
        next if program.line_number?(destination)

        console_io.print_line(
          "Line number #{destination} not found in line #{line_number_index}"
        )
        retval = false
      end
    end

    retval
  end

  def execute_core(interpreter)
    unless @destination.nil?
      line_number = @destination
      index = interpreter.statement_start_index(line_number, 0)

      raise(BASICSyntaxError, 'Line number not found') if index.nil?

      destination = LineStmtMod.new(line_number, 0, index)
      interpreter.next_line_stmt_mod = destination
    end

    unless @destinations.nil?
      values = @expression.evaluate(interpreter)

      raise(BASICExpressionError, 'Expecting one value') unless values.size == 1

      value = values[0]

      raise(BASICSyntaxError, 'Invalid value') unless
        value.numeric_constant?

      io = interpreter.trace_out
      io.trace_output(' ' + @expression.to_s + ' = ' + value.to_s)
      index = value.to_i

      raise BASICRuntimeError.new(:te_val_out) if
        index < 1 || index > @destinations.size

      # get destination in list
      line_number = @destinations[index - 1]
      index = interpreter.statement_start_index(line_number, 0)

      raise(BASICSyntaxError, 'Line number not found') if index.nil?

      destination = LineStmtMod.new(line_number, 0, index)
      interpreter.next_line_stmt_mod = destination
    end
  end

  def renumber(renumber_map)
    unless @destination.nil?
      @destination = renumber_map[@destination]
      @linenums = [@destination]
      @tokens[-1] = NumericConstantToken.new(@destination.line_number)
    end

    return if @destinations.nil?

    new_destinations = []
    @destinations.each do |destination|
      new_destinations << renumber_map[destination]
    end

    i = 0
    index = 0
    @tokens.each do |token|
      index = i if token.to_s == 'OF'
      i += 1
    end

    new_destinations.each do |destination|
      @tokens[index + 1] =
        NumericConstantToken.new(destination.line_number)

      index += 2
    end

    @destinations = new_destinations
    @linenums = @destinations
  end
end

# common functions for IF statements
class AbstractIfStatement < AbstractStatement
  def initialize(line_number, keywords, tokens_lists)
    super

    if tokens_lists.class.to_s == 'Hash'
      @expression = parse_expression(tokens_lists['expr'])
      @errors << 'TAB() not allowed' if @expression.has_tab

      @warnings << 'Constant expression' if
        !@expression.nil? && @expression.constant

      @destination, @statement = parse_target(line_number, tokens_lists['then'])
      @else_dest = nil
      @else_dest, @else_stmt = parse_target(line_number, tokens_lists['else']) if
        tokens_lists.key?('else')

      unless @statement.nil?
        @errors << 'Invalid substatement' unless @statement.may_be_if_sub
        @warnings += @statement.warnings
      end

      unless @else_stmt.nil?
        @errors << 'Invalid substatement' unless @else_stmt.may_be_if_sub
        @warnings += @else_stmt.warnings
      end

      unless @destination.nil?
        if @destination > line_number
          @comprehension_effort += 1
        else
          @comprehension_effort += 2
        end
      end

      unless @else_dest.nil?
        if @else_dest > line_number
          @comprehension_effort += 1
        else
          @comprehension_effort += 2
        end
      end

      @elements[:numerics] = make_numeric_references
      @elements[:num_symbols] = make_num_symbol_references
      @elements[:strings] = make_string_references
      @elements[:booleans] = make_boolean_references
      @elements[:text_symbols] = make_text_symbol_references
      @elements[:variables] = make_variable_references
      @elements[:operators] = make_operator_references
      @elements[:functions] = make_function_references
      @elements[:userfuncs] = make_userfunc_references

      @comprehension_effort += @expression.comprehension_effort unless
        @expression.nil?

      @linenums = make_linenum_references
    else
      begin
        stack = parse_if(tokens_lists)
        @expression = parse_expression(stack['expr'])

        @errors << 'TAB() not allowed' if
          !@expression.nil? && @expression.has_tab

        @warnings << 'Constant expression' if
          !@expression.nil? && @expression.constant

        @destination, @statement = parse_target(line_number, stack['then'])
        @else_dest = nil
        @else_dest, @else_stmt = parse_target(line_number, stack['else']) if
          stack.key?('else')

        unless @statement.nil?
          @errors << 'Invalid substatement' unless @statement.may_be_if_sub
          @warnings += @statement.warnings
        end

        unless @else_stmt.nil?
          @errors << 'Invalid substatement' unless @else_stmt.may_be_if_sub
          @warnings += @else_stmt.warnings
        end

        unless @destination.nil?
          if @destination > line_number
            @comprehension_effort += 1
          else
            @comprehension_effort += 2
          end
        end

        unless @else_dest.nil?
          if @else_dest > line_number
            @comprehension_effort += 1
          else
            @comprehension_effort += 2
          end
        end

        @elements[:numerics] = make_numeric_references
        @elements[:num_symbols] = make_num_symbol_references
        @elements[:strings] = make_string_references
        @elements[:booleans] = make_boolean_references
        @elements[:text_symbols] = make_text_symbol_references
        @elements[:variables] = make_variable_references
        @elements[:operators] = make_operator_references
        @elements[:functions] = make_function_references
        @elements[:userfuncs] = make_userfunc_references

        @comprehension_effort += @expression.comprehension_effort unless
          @expression.nil?

        @linenums = make_linenum_references
      rescue BASICExpressionError => e
        @errors << 'Syntax Error: ' + e.message
      end
    end

    @comprehension_effort += @statement.comprehension_effort unless @statement.nil?
    @comprehension_effort += @else_stmt.comprehension_effort unless @else_stmt.nil?

    @mccabe += 1
    @mccabe += @statement.mccabe unless @statement.nil?
    @mccabe += @else_stmt.mccabe unless @else_stmt.nil?

    @is_if_no_else = @else_dest.nil? && @else_stmt.nil?
  end

  def set_for_lines(interpreter, line_stmt_mod, program)
    @statement.set_for_lines(interpreter, line_stmt_mod, program) unless
      @statement.nil?

    @else_stmt.set_for_lines(interpreter, line_stmt_mod, program) unless
      @else_stmt.nil?
  end

  private

  def parse_if(tokens_lists)
    stack = []
    new_dict = { 'expr' => [], 'then' => [] }
    stack << new_dict
    dict = stack[-1]
    state = 1

    tokens_lists.each do |tokens_list|
      handled = false
      case state
      when 1
        if tokens_list == 'THEN'
          state = 2
        elsif tokens_list.class.to_s == 'KeywordToken'
          if tokens_list.to_s == 'GOTO'
            state = 4
          else
            dict['expr'] << tokens_list
          end
        else
          dict['expr'] += tokens_list
        end
        handled = true
      when 2
        unless handled
          if tokens_list == 'ELSE'
            dict['else'] = []
            state = 3
          elsif tokens_list == 'IF' && dict['then'].empty?
            new_dict = { 'expr' => [], 'then' => [] }
            dict['then'] = new_dict
            stack << new_dict
            dict = stack[-1]
            state = 1
          elsif tokens_list.class.to_s == 'KeywordToken'
            dict['then'] << tokens_list
          else
            dict['then'] += tokens_list
          end
          handled = true
        end
      when 3
        unless handled
          if tokens_list == 'ELSE'
            stack.pop
            # TODO: exit if stack.empty
            dict = stack[-1]
            dict['else'] = []
          elsif tokens_list == 'IF' && dict['else'].empty?
            new_dict = { 'expr' => [], 'then' => [] }
            dict['else'] = new_dict
            stack << new_dict
            dict = stack[-1]
            state = 1
          elsif tokens_list.class.to_s == 'KeywordToken'
            dict['else'] << tokens_list
          else
            dict['else'] += tokens_list
          end
          handled = true
        end
      when 4
        unless handled
          if dict['then'].empty?
            dict['then'] += tokens_list
          else
            raise(BASICSyntaxError, 'THEN without matching IF')
          end
          handled = true
        end
      end
    end

    stack[0]
  end

  def print_dict(dict)
    expr_s = '['
    x0 = dict['expr']

    x0.each do |x|
      if x.class.to_s == 'Array'
        expr_s += '[' + x.map(&:to_s).join(', ') + ']'
      else
        expr_s += x.to_s
      end
      expr_s += ', '
    end

    expr_s += ']'
    x1 = dict['then']

    if x1.class.to_s == 'Array'
      ax1 = []
      x1.each do |x|
        if x.class.to_s == 'Array'
          ax1 << '[' + x.map(&:to_s).join(', ') + ']'
        else
          ax1 << x.to_s
        end
      end
      then_s = '[' + ax1.join(', ') + ']'
    else
      then_s = 'DICT'
    end

    else_s = ''

    if dict.key?('else')
      x2 = dict['else']
      if x2.class.to_s == 'Array'
        ax2 = []
        x2.each do |x|
          if x.class.to_s == 'Array'
            ax2 << '[' + x.map(&:to_s).join(', ') + ']'
          else
            ax2 << x.to_s
          end
        end
        else_s = '[' + ax2.join(', ') + ']'
      else
        else_s = 'DICT'
      end
    end
  end

  def make_numeric_references
    nums = []
    nums += @expression.numerics unless @expression.nil?
    nums += @statement.numerics unless @statement.nil?
    nums += @else_stmt.numerics unless @else_stmt.nil?
    nums
  end

  def make_num_symbol_references
    nums = []
    nums += @expression.num_symbols unless @expression.nil?
    nums += @statement.num_symbols unless @statement.nil?
    nums += @else_stmt.num_symbols unless @else_stmt.nil?
    nums
  end

  def make_string_references
    strs = []
    strs += @expression.strings unless @expression.nil?
    strs += @statement.strings unless @statement.nil?
    strs += @else_stmt.strings unless @else_stmt.nil?
    strs
  end

  def make_boolean_references
    bools = []
    bools += @expression.booleans unless @expression.nil?
    bools += @statement.booleans unless @statement.nil?
    bools += @else_stmt.booleans unless @else_stmt.nil?
    bools
  end

  def make_text_symbol_references
    strs = []
    strs += @expression.text_symbols unless @expression.nil?
    strs += @statement.text_symbols unless @statement.nil?
    strs += @else_stmt.text_symbols unless @else_stmt.nil?
    strs
  end

  def make_variable_references
    vars = []
    vars += @expression.variables unless @expression.nil?
    vars += @statement.variables unless @statement.nil?
    vars += @else_stmt.variables unless @else_stmt.nil?
    vars
  end

  def make_operator_references
    vars = []
    vars += @expression.operators unless @expression.nil?
    vars += @statement.operators unless @statement.nil?
    vars += @else_stmt.operators unless @else_stmt.nil?
    vars
  end

  def make_function_references
    vars = []
    vars += @expression.functions unless @expression.nil?
    vars += @statement.functions unless @statement.nil?
    vars += @else_stmt.functions unless @else_stmt.nil?
    vars
  end

  def make_userfunc_references
    vars = []
    vars += @expression.userfuncs unless @expression.nil?
    vars += @statement.userfuncs unless @statement.nil?
    vars += @else_stmt.userfuncs unless @else_stmt.nil?
    vars
  end

  def make_linenum_references
    nums = []
    nums << @destination unless @destination.nil?
    nums << @else_dest unless @else_dest.nil?
    nums
  end

  public

  def uncache_core
    @expression.uncache unless @expression.nil?
    @statement.uncache unless @statement.nil?
    @else_stmt.uncache unless @else_stmt.nil?
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?
    lines << @destination.dump unless @destination.nil?
    lines += @statement.dump unless @statement.nil?
    lines << @else_dest.dump unless @else_dest.nil?
    lines += @else_stmt.dump unless @else_stmt.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def gotos(user_function_start_lines)
    goto_refs = []

    goto_refs << TransferRefLineStmt.new(@destination, 0, :ifthen) unless
      @destination.nil?

    goto_refs += @statement.gotos(user_function_start_lines) unless
      @statement.nil?

    goto_refs << TransferRefLineStmt.new(@else_dest, 0, :ifthen) unless
      @else_dest.nil?

    goto_refs += @else_stmt.gotos(user_function_start_lines) unless
      @else_stmt.nil?

    goto_refs
  end

  def okay(program, console_io, line_number_index)
    retval = true

    if @destination.nil? && @statement.nil?
      console_io.print_line(
        "Invalid or missing line number in line #{line_number_index}"
      )
    end

    unless @destination.nil? || program.line_number?(@destination)
      console_io.print_line(
        "Line number #{@destination} not found in line #{line_number_index}"
      )
      retval = false
    end

    unless @else_dest.nil? || program.line_number?(@else_dest)
      console_io.print_line(
        "Line number #{@else_dest} not found in line #{line_number_index}"
      )
      retval = false
    end

    retval
  end

  def renumber(renumber_map)
    unless @destination.nil?
      @destination = renumber_map[@destination]
      index = 0
      i = 0

      @tokens.each do |token|
        index = i if token.to_s == 'THEN'
        i += 1
      end

      @tokens[index + 1] = NumericConstantToken.new(@destination.line_number)
    end

    unless @else_dest.nil?
      @else_dest = renumber_map[@else_dest]
      @tokens[-1] = NumericConstantToken.new(@else_dest.line_number)
    end

    @linenums = make_linenum_references
  end

  def execute_core(interpreter)
    values = @expression.evaluate(interpreter)

    raise(BASICExpressionError, 'Too many or too few values') unless
      values.size == 1

    result = values[0]

    result = BooleanConstant.new(result) unless
      result.class.to_s == 'BooleanConstant'

    if result.value
      unless @destination.nil?
        line_number = @destination
        index = interpreter.statement_start_index(line_number, 0)

        raise(BASICSyntaxError, 'Line number not found') if index.nil?

        destination = LineStmtMod.new(line_number, 0, index)
        interpreter.next_line_stmt_mod = destination
      end

      if !@statement.nil? && !@else_stmt.nil? && $options['extend_if'].value
        # go to next numbered line, not next statement
        next_line_stmt_mod = interpreter.find_next_line
        interpreter.next_line_stmt_mod = next_line_stmt_mod
      end

      @statement.execute_core(interpreter) unless @statement.nil?
    else
      unless @else_dest.nil?
        line_number = @else_dest
        index = interpreter.statement_start_index(line_number, 0)

        raise(BASICSyntaxError, 'Line number not found') if index.nil?

        destination = LineStmtMod.new(line_number, 0, index)
        interpreter.next_line_stmt_mod = destination
      end

      if @else_dest.nil? && @else_stmt.nil? && $options['extend_if'].value
        # go to next numbered line, not next statement
        next_line_stmt_mod = interpreter.find_next_line
        interpreter.next_line_stmt_mod = next_line_stmt_mod
      end

      @else_stmt.execute_core(interpreter) unless @else_stmt.nil?
    end

    s = ' ' + @expression.to_s + ': ' + result.to_s
    io = interpreter.trace_out
    io.trace_output(s)
  end

  def number_for_stmts
    number = 0

    number += @statement.number_for_stmts unless @statement.nil?
    number += @else_stmt.number_for_stmts unless @else_stmt.nil?
    
    number
  end

  private

  def parse_target(line_number, tokens)
    destination = nil
    statement = nil

    if tokens.class.to_s == 'Hash'
      statement = IfStatement.new(line_number, nil, tokens)
    elsif tokens.size == 1 && tokens[0].numeric_constant?
      number = IntegerConstant.new(tokens[0])
      destination = LineNumber.new(number)
    else
      statement_factory = StatementFactory.instance

      text = tokens.map(&:to_s).join(' ')
      statement =
        statement_factory.create_statement(line_number, text, tokens.flatten)

      @errors += statement.errors
    end

    [destination, statement]
  end
end

# IF/THEN
class IfStatement < AbstractIfStatement
  def self.lead_keywords
    [
      [KeywordToken.new('IF')]
    ]
  end

  def self.extra_keywords
    %w[THEN ELSE]
  end

  def initialize(_, _, _)
    super
  end

  private

  def parse_expression(tokens)
    expression = nil

    begin
      expression = ValueExpressionSet.new(tokens, :scalar)
    rescue BASICExpressionError => e
      @errors << e.message
    end

    expression
  end
end

# INPUT
class InputStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('INPUT')],
      [KeywordToken.new('INP')]
    ]
  end

  include FileFunctions
  include InputFunctions

  def initialize(_, _, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions(items, :scalar, false)

      @items.each do |item|
        @errors << 'TAB() not allowed' if item.has_tab
      end

      @file_tokens = extract_file_handle(@items)
      @prompt = extract_prompt(@items)
      @elements = make_references(@items, @file_tokens, @prompt)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :read)

    prompt = nil

    unless @prompt.nil?
      prompts = @prompt.evaluate(interpreter)
      prompt = prompts[0]
    end

    # create list of variables with subscripts
    item_names = []

    @items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        item_names << target
      end
    end

    # get all of the needed values
    if fh.nil?
      # from console
      values = input_values(fhr, interpreter, prompt, item_names.size)
      fhr.implied_newline
    else
      # from file
      values = fhr.input(interpreter)
    end

    raise BASICRuntimeError.new(:te_too_few) if values.size < item_names.size

    name_value_pairs =
      zip(item_names, values[0..item_names.length])

    name_value_pairs.each do |hash|
      variable = hash['name']
      value = hash['value']
      interpreter.set_value(variable, value)
    end

    interpreter.clear_previous_lines
  end
end

# INPUT$
class InputCharStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('INPUT$')]
    ]
  end

  include FileFunctions
  include InputFunctions

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions(items, :scalar, false)

      @items.each do |item|
        @errors << 'TAB() not allowed' if item.has_tab
      end

      @file_tokens = extract_file_handle(@items)
      @prompt = extract_prompt(@items)
      @elements = make_references(@items, @file_tokens, @prompt)
      @mccabe += 1
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :read)

    prompt = nil

    unless @prompt.nil?
      prompts = @prompt.evaluate(interpreter)
      prompt = prompts[0]
    end

    if fh.nil?
      values = input_values(fhr, interpreter, prompt, @items.size)
      fhr.implied_newline
    else
      values = fhr.input(interpreter)
    end

    name_value_pairs =
      zip(@items, values[0..@items.length])

    name_value_pairs.each do |hash|
      variables = hash['name'].evaluate(interpreter)
      variable = variables[0]
      value = NumericConstant.new(hash['value'].ord)
      interpreter.set_value(variable, value)
    end

    interpreter.clear_previous_lines
  end

  private

  def input_values(fhr, _, _, count)
    values = []
    values << fhr.read_char while values.size < count

    values
  end
end

# common functions for LET and LET-less statements
class AbstractLetStatement < AbstractStatement
  def initialize(_, _, _)
    super
  end

  def uncache_core
    @assignment.uncache
  end

  def dump
    lines = []

    lines += @assignment.dump unless @assignment.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def gotos(user_function_start_lines)
    return [] if @assignment.nil?

    @assignment.destinations(user_function_start_lines)
  end
end

# common functions for scalar LET and LET-less statement
class AbstractScalarLetStatement < AbstractLetStatement
  def initialize(_, _, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[3, '>=']]

    if check_template(tokens_lists, template)
      begin
        @assignment = Assignment.new(tokens_lists[0], :scalar)

        if @assignment.count_target.zero?
          @errors << 'Assignment must have left-hand value(s)'
        end

        if @assignment.count_value.zero?
          @errors << 'Assignment must have right-hand value(s)'
        end

        @errors << 'TAB() not allowed' if @assignment.has_tab

        @warnings << 'Extra values ignored' if
          @assignment.count_value > @assignment.count_target

        @warnings += @assignment.warnings
        @elements = make_references(nil, @assignment)
        @comprehension_effort += @assignment.comprehension_effort
      rescue BASICExpressionError => e
        @errors << e.message
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    l_values = @assignment.eval_target(interpreter)

    r_values = @assignment.eval_value(interpreter)

    # more left-hand values -> repeat last rhs
    # more rhs -> drop extra values
    l_values.each_with_index do |l_value, index|
      j = [index, r_values.count - 1].min
      r_value = r_values[j]

      # if l_value is a function name
      # replace with current function name
      l_value = interpreter.current_user_function if
        l_value.class.to_s == 'UserFunction'

      interpreter.set_value(l_value, r_value)
    end
  end
end

# LET
class LetStatement < AbstractScalarLetStatement
  def self.lead_keywords
    [
      [KeywordToken.new('LET')]
    ]
  end

  def initialize(_, _, _)
    super
  end
end

# LET-less assignment
class LetLessStatement < AbstractScalarLetStatement
  def self.lead_keywords
    [
      []
    ]
  end

  def initialize(_, _, _)
    super
  end
end

# LINE INPUT
class LineInputStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('LINE'), KeywordToken.new('INPUT')],
      [KeywordToken.new('INPUT'), KeywordToken.new('LINE')],
      [KeywordToken.new('LINPUT')],
      [KeywordToken.new('LIN')]
    ]
  end

  include FileFunctions
  include InputFunctions

  def initialize(_, _, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions(items, :scalar, false)

      @items.each do |item|
        @errors << 'TAB() not allowed' if item.has_tab
      end

      @file_tokens = extract_file_handle(@items)
      @prompt = extract_prompt(@items)
      @elements = make_references(@items, @file_tokens, @prompt)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :read)

    prompt = nil

    unless @prompt.nil?
      prompts = @prompt.evaluate(interpreter)
      prompt = prompts[0]
    end

    if fh.nil?
      values = input_values(fhr, interpreter, prompt, @items.size)
      fhr.implied_newline
    else
      values = fhr.line_input(interpreter)
    end

    name_value_pairs =
      zip(@items, values[0..@items.length])

    name_value_pairs.each do |hash|
      variables = hash['name'].evaluate(interpreter)
      variable = variables[0]
      value = hash['value']
      interpreter.set_value(variable, value)
    end

    interpreter.clear_previous_lines
  end

  private

  def input_values(fhr, interpreter, prompt, count)
    values = []

    while values.size < count
      remaining = count - values.size
      fhr.prompt(prompt, remaining)
      values += fhr.line_input(interpreter)

      prompt = nil
    end

    values
  end
end

# NEXT
class NextStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('NEXT')],
      [KeywordToken.new('NEX')]
    ]
  end

  attr_reader :control

  def initialize(_, keywords, tokens_lists)
    super

    template = [[1]]

    if check_template(tokens_lists, template)
      # parse control variable
      @control = nil
      if tokens_lists[0][0].variable?
        variable_name = VariableName.new(tokens_lists[0][0])
        @control = Variable.new(variable_name, :scalar, [], [])
        controlx = XrefEntry.new(@control.to_s, nil, false)
        @elements[:variables] = [controlx]
      else
        @errors << "Invalid control variable #{tokens_lists[0][0]}"
      end
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = [@control.dump]

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    fornext_control = interpreter.retrieve_fornext(@control)

    if $options['match_fornext'].value
      # check control variable matches current loop
      expected = interpreter.top_fornext
      actual = fornext_control.control

      if actual != expected
        raise(BASICSyntaxError,
              "Found NEXT #{actual} when expecting #{expected}")
      end
    end

    bump_early = fornext_control.bump_early?
    
    # change control variable value for FOR-WHILE and FOR-UNTIL
    fornext_control.bump_control(interpreter) if bump_early

    # check control variable value
    # if matches end value, stop here
    terminated = fornext_control.terminated?(interpreter)
    io = interpreter.trace_out
    s = ' terminated:' + terminated.to_s
    io.trace_output(s)

    if terminated
      fornext_control.bump_control(interpreter) if
        $options['fornext_one_beyond'].value

      interpreter.unlock_variable(@control) if $options['lock_fornext'].value
      interpreter.exit_fornext(fornext_control.forget, fornext_control.control)
    else
      # set next line from top item
      interpreter.next_line_stmt_mod = fornext_control.start_line_stmt_mod
      # change control variable value for FOR-TO
      fornext_control.bump_control(interpreter) unless bump_early
    end
  end
end

# ON ERROR GOTO
class OnErrorStatement < AbstractStatement
  def self.lead_keywords
    [
      [
        KeywordToken.new('ON'),
        KeywordToken.new('ERROR'),
        KeywordToken.new('GOTO')
      ]
    ]
  end

  def initialize(line_number, keywords, tokens_lists)
    super

    @destination = nil

    template = [[1]]

    if check_template(tokens_lists, template)
      destinations = tokens_lists[0]
      line_nums = split_tokens(destinations, false)
      tokens = line_nums[0]
      token = tokens[0]

      if token.numeric_constant?
        if token.to_i == 0
          @destination = nil
          @linenums = []
        else
          number = IntegerConstant.new(token) 
          @destination = LineNumber.new(number)
          @linenums = [@destination]

          if @destination > line_number
            @comprehension_effort += 1
          else
            @comprehension_effort += 2
          end
        end
      else
        @errors << "Invalid line number #{destination}"
      end

      @mccabe += 1
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    lines << @destination.dump unless @destination.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def gotos(_)
    destinations = []

    destinations << TransferRefLineStmt.new(@destination, 0, :onerror) unless
      @destination.nil?

    destinations
  end

  def okay(program, console_io, line_number_index)
    retval = true

    unless @destination.nil?
      unless program.line_number?(@destination)
        console_io.print_line(
          "Line number #{@destination} not found in line #{line_number_index}"
        )
        retval = false
      end
    end

    retval
  end

  def execute_core(interpreter)
    interpreter.seterrorgoto(@destination)
  end

  def renumber(renumber_map)
    unless @destination.nil?
      @destination = renumber_map[@destination]
      @linenums = [@destination]
      @tokens[-1] = NumericConstantToken.new(@destination.line_number)
    end
  end
end

# ON GOTO
class OnStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ON')]
    ]
  end

  def self.extra_keywords
    %w[GOTO THEN]
  end

  def initialize(line_number, keywords, tokens_lists)
    super

    @destinations = nil
    @expression = nil

    template1 = [[1, '>='], 'GOTO', [1, '>=']]
    template2 = [[1, '>='], 'THEN', [1, '>=']]

    if check_template(tokens_lists, template1) ||
       check_template(tokens_lists, template2)
      expression = tokens_lists[0]

      begin
        @expression = ValueExpressionSet.new(expression, :scalar)
      rescue BASICExpressionError => e
        @errors << e.message
      end

      @errors << 'TAB() not allowed' if @expression.has_tab
      @warnings << 'Constant expression' if @expression.constant
      @elements = make_references(nil, @expression)

      destinations = tokens_lists[2]
      line_nums = split_tokens(destinations, false)
      @destinations = []

      line_nums.each do |line_num|
        if line_num.size == 1
          token = line_num[0]
          if token.numeric_constant?
            number = IntegerConstant.new(token)
            @destinations << LineNumber.new(number)
          else
            @errors << "Invalid line number #{token}"
          end
        else
          @errors << "Invalid line specification #{line_num}"
        end
      end

      @linenums = @destinations
      @comprehension_effort += @expression.comprehension_effort

      @destinations.each do |destination|
        if destination > line_number
          @comprehension_effort += 1
        else
          @comprehension_effort += 2
        end
      end

      @mccabe += @destinations.size
    else
      @errors << 'Syntax error'
    end
  end

  def uncache_core
    @expression.uncache
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?

    @destinations.each { |destination| lines << destination.dump } unless
      @destinations.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def gotos(_)
    goto_refs = []

    @destinations.each do |goto|
      goto_refs << TransferRefLineStmt.new(goto, 0, :goto)
    end

    goto_refs
  end

  def okay(program, console_io, line_number_index)
    retval = true

    unless @destinations.nil?
      @destinations.each do |destination|
        unless program.line_number?(destination)
          console_io.print_line(
            "Line number #{destination} not found in line #{line_number_index}"
          )
          retval = false
        end
      end
    end

    retval
  end

  def execute_core(interpreter)
    values = @expression.evaluate(interpreter)

    raise(BASICExpressionError, 'Expecting one value') unless values.size == 1

    value = values[0]

    raise(BASICExpressionError, 'Invalid value') unless value.numeric_constant?

    io = interpreter.trace_out
    io.trace_output(' ' + @expression.to_s + ' = ' + value.to_s)
    index = value.to_i

    raise BASICRuntimeError.new(:te_val_out) if
      index < 1 || index > @destinations.size

    # get destination in list
    line_number = @destinations[index - 1]
    index = interpreter.statement_start_index(line_number, 0)

    raise(BASICSyntaxError, 'Line number not found') if index.nil?

    destination = LineStmtMod.new(line_number, 0, index)
    interpreter.next_line_stmt_mod = destination
  end

  def renumber(renumber_map)
    new_destinations = []

    @destinations.each do |destination|
      new_destinations << renumber_map[destination]
    end

    i = 0
    index = 0
    @tokens.each do |token|
      index = i if token.to_s == 'THEN'
      index = i if token.to_s == 'GOTO'
      i += 1
    end

    new_destinations.each do |destination|
      @tokens[index + 1] = NumericConstantToken.new(destination.line_number)

      index += 2
    end

    @destinations = new_destinations
    @linenums = @destinations
  end
end

# OPEN
class OpenStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('OPEN')],
      [KeywordToken.new('OPE')]
    ]
  end

  def self.extra_keywords
    %w[FOR INPUT OUTPUT AS FILE]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template_input_as = [[1, '>='], 'FOR', 'INPUT', 'AS', [1, '>=']]

    template_input_as_file =
      [[1, '>='], 'FOR', 'INPUT', 'AS', 'FILE', [1, '>=']]

    template_output_as = [[1, '>='], 'FOR', 'OUTPUT', 'AS', [1, '>=']]

    template_output_as_file =
      [[1, '>='], 'FOR', 'OUTPUT', 'AS', 'FILE', [1, '>=']]

    template_update = [[2, '>=']]

    ### TODO: add template OPEN filename FOR MEMORY AS FILE #n

    if check_template(tokens_lists, template_input_as) ||
       check_template(tokens_lists, template_input_as_file)

      @filename_expression = ValueExpressionSet.new(tokens_lists[0], :scalar)
      @errors << 'TAB() not allowed' if @filename_expression.has_tab
      @filenum_expression = ValueExpressionSet.new(tokens_lists[-1], :scalar)
      @errors << 'TAB() not allowed' if @filenum_expression.has_tab

      @elements =
        make_references(nil, @filename_expression, @filenum_expression)

      @mode = :read
      @comprehension_effort += @filenum_expression.comprehension_effort
      @comprehension_effort += @filename_expression.comprehension_effort

    elsif check_template(tokens_lists, template_output_as) ||
          check_template(tokens_lists, template_output_as_file)

      @filename_expression = ValueExpressionSet.new(tokens_lists[0], :scalar)
      @errors << 'TAB() not allowed' if @filename_expression.has_tab
      @filenum_expression = ValueExpressionSet.new(tokens_lists[-1], :scalar)
      @errors << 'TAB() not allowed' if @filenum_expression.has_tab

      @elements =
        make_references(nil, @filename_expression, @filenum_expression)

      @mode = :print
      @comprehension_effort += @filenum_expression.comprehension_effort
      @comprehension_effort += @filename_expression.comprehension_effort

    elsif check_template(tokens_lists, template_update)

      split_lists = split_tokens(tokens_lists[0], false)

      @filenum_expression = ValueExpressionSet.new(split_lists[0], :scalar)
      @errors << 'TAB() not allowed' if @filenum_expression.has_tab
      @filename_expression = ValueExpressionSet.new(split_lists[1], :scalar)
      @errors << 'TAB() not allowed' if @filename_expression.has_tab

      @elements =
        make_references(nil, @filename_expression, @filenum_expression)

      @mode = :memory
      @comprehension_effort += @filenum_expression.comprehension_effort
      @comprehension_effort += @filename_expression.comprehension_effort

    else
      @errors << 'Syntax error'
    end
  end

  def uncache_core
    @filenum_expression.uncache
    @filename_expression.uncache
  end

  def dump
    lines = []

    lines += @filename_expression.dump unless @filename_expression.nil?
    lines += @filenum_expression.dump unless @filenum_expression.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    filenames = @filename_expression.evaluate(interpreter)
    filename = filenames[0]
    fhs = @filenum_expression.evaluate(interpreter)
    fh = FileHandle.new(fhs[0])
    interpreter.open_file(filename, fh, @mode)
  end
end

# OPTION
class OptionStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('OPTION')]
    ]
  end

  def self.extra_keywords
    $options.keys.map(&:upcase)
  end

  def initialize(_, keywords, tokens_lists)
    super

    extras = OptionStatement.extra_keywords
    template = [extras, [1, '>=']]

    if check_template(tokens_lists, template)
      kwd = tokens_lists[0].to_s.upcase
      @key = kwd.downcase

      if $options[@key].types.include?(:runtime)
        expression_tokens = split_tokens(tokens_lists[1], true)
        @expression = ValueExpressionSet.new(expression_tokens[0], :scalar)
        @errors << 'TAB() not allowed' if @expression.has_tab

        @elements = make_references(nil, @expression)
        @comprehension_effort += @expression.comprehension_effort
      else
        @errors << 'Cannot set option ' + kwd
      end
    elsif tokens_lists.size == 1 &&
          extras.include?(tokens_lists[0].to_s)
      kwd = tokens_lists[0].to_s.upcase
      @key = kwd.downcase

      @errors << 'Cannot set option ' + kwd unless
        $options[@key].types.include?(:runtime)
    else
      @errors << 'Syntax error'
    end
  end

  def uncache_core
    @expression.uncache unless @expression.nil?
  end

  def dump
    lines = []

    lines += @expression.dump unless @expression.nil?

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    if @expression.nil?
      interpreter.pop_option(@key)
    else
      values = @expression.evaluate(interpreter)
      value0 = values[0]

      interpreter.push_option(@key, value0.to_v)
    end
  end
end

# PRINT
class PrintStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('PRINT')],
      [KeywordToken.new('PRI')],
      [KeywordToken.new('&')]
    ]
  end

  include FileFunctions
  include PrintFunctions

  def self.extra_keywords
    ['USING']
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    # build list: exp, cc, exp, cc, 'USING' exp, cc, exp, cc
    tokens = tokens_lists.flatten
    list = split_keywords(tokens)

    @items = []

    if list.empty?
      expressions = tokens_to_expressions([], :scalar)
      @items << expressions
    else
      list.each do |item|
        if item.class.to_s == 'Array'
          tokens_lists = split_tokens(item, true)
          expressions = tokens_to_expressions(tokens_lists, :scalar)
          @items << expressions
        else
          @items << item
        end
      end
    end

    # if list first item is expression
    #   extract possible file handle
    @file_tokens = nil
    unless @items.empty?
      if @items[0].class.to_s == 'Array'
        @file_tokens = extract_file_handle(@items[0]) unless
          @items[0].empty?
      end
    end

    # end with
    #   @file_tokens : exp or nil
    #   @items : list either expression, cc, or keyword

    # if item is keyword then it must be 'USING'
    @items.each do |item|
      unless item.class.to_s == 'Array'
        @errors << 'Syntax error' unless
          item.keyword? && item.to_s == 'USING'
      end
    end

    @elements = make_references(nil, @file_tokens)

    @items.each do |item|
      if item.class.to_s == 'Array'
        elements = make_references(item)
        elements.each { |k, v| @elements[k] += v }
        item.each { |it| @comprehension_effort += it.comprehension_effort }
      elsif item.keyword?
        @comprehension_effort += 1
      end
    end

    ## @errors << 'Delimiter required' if any_implied_carriage(@items)
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    j = 0
    while j < @items.size
      item = @items[j]

      if item.class.to_s == 'Array'
        i = 0
        last_was_carriage = true

        while i < item.size
          it = item[i]

          # insert an implicit carriage control
          fhr.implied unless it.carriage_control? || last_was_carriage

          if it.carriage_control?
            it.print(fhr)
          else
            it.print(fhr, interpreter)
          end

          last_was_carriage = it.carriage_control?

          i += 1
        end
      else
        # item must be 'USING'
        j += 1

        raise BASICRuntimeError.new(:te_no_fmt) if j >= @items.size

        # extract formats
        item = @items[j]

        format_spec, items = extract_format(item, interpreter)

        raise BASICRuntimeError.new(:te_no_fmt) if format_spec.nil?

        # split format spec into formats
        formats = split_format(format_spec)
        fhr = interpreter.console_io

        # FIX: if item is not Array, throw exception

        last_was_carriage = true

        i = 0

        formats.each do |format|
          constant = nil

          if format.wants_item
            # skip all of the separators
            i += 1 while i < items.size && items[i].carriage_control?

            raise BASICRuntimeError.new(:te_few_fmt) if i == items.size

            constants = items[i].evaluate(interpreter)

            constant = constants[0]

            i += 1
          end

          text = format.format(constant)
          text.print(fhr)

          last_was_carriage = false
        end

        while i < items.size
          item = items[i]

          # insert an implicit carriage control
          fhr.implied unless item.carriage_control? || last_was_carriage

          if item.carriage_control?
            item.print(fhr)
          else
            item.print(fhr, interpreter)
          end

          last_was_carriage = item.carriage_control?

          i += 1
        end
      end

      j += 1
    end
  end
end

# PUT
class PutStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('PUT')]
    ]
  end

  include FileFunctions

  def initialize(line_number, keywords, tokens_lists)
    super

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      if items.size == 3
        line_no = items[1]
        if line_no.empty?
          @errors << 'No line number'
        else
          token = line_no[0]
          begin
            number = IntegerConstant.new(token)
            @line_number = LineNumber.new(number)

            if @line_number > line_number
              @comprehension_effort += 1
            else
              @comprehension_effort += 2
            end
          rescue BASICSyntaxError => e
            @errors << e.message
          end
        end
      else
        @errors << 'Syntax error'
      end

      @items = tokens_to_expressions(items, :scalar)

      @items.each do |item|
        @errors << 'TAB() not allowed' if item.has_tab
      end

      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []
    @items.each { |item| lines += item.dump }
    lines
  end

  def okay(program, console_io, line_number_index)
    retval = true

    unless program.line_number?(@line_number)
      console_io.print_line(
        "Line number #{@line_number} not found in line #{line_number_index}"
      )
      retval = false
    end

    retval
  end

  def execute_core(interpreter)
    file_no = @items[0]
    file_num = file_no.evaluate(interpreter)
    fh = FileHandle.new(file_num[0])
    fhr = interpreter.get_file_handler(fh, :memory)

    rec_no = @items[2]
    rec_num = rec_no.evaluate(interpreter)
    rec_number = rec_num[0].to_i

    write_items = interpreter.get_record_write_variables(@line_number)

    # write variables from record (use ValueExpressions)
    items = []
    write_items.each do |item|
      values = item.evaluate(interpreter)
      items << values[0].to_s
    end

    # format variables to string
    record = items.join(', ')
    fhr.write_record(record, rec_number)
  end

  def renumber(renumber_map)
    @line_number = renumber_map[@line_number]
    @token_index = -1
    i = 0
    num_commas = 1
    @tokens.each do |token|
      @token_index = i if token.numeric_constant? && num_commas == 1

      num_commas += 1 if token.separator?

      i += 1
    end
    @tokens[@token_index] = NumericConstantToken.new(@line_number.line_number)
  end

  private

  def tokens_to_expressions(tokens_lists, shape)
    items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_expression(items, tokens_list, shape)
      end
    end

    items
  end

  def add_expression(items, tokens, shape)
    items << ValueExpressionSet.new(tokens, shape)
  rescue BASICExpressionError
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" is not a value or operator'
  end
end

# RANDOMIZE
class RandomizeStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('RANDOMIZE')],
      [KeywordToken.new('RANDOM')],
      [KeywordToken.new('RAN')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    interpreter.new_random
  end
end

# READ
class ReadStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('READ')],
      [KeywordToken.new('REA')]
    ]
  end

  include FileFunctions
  include ReadFunctions

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions(items, :scalar, false)

      @items.each do |item|
        @errors << 'TAB() not allowed' if item.has_tab
      end

      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    ds = interpreter.get_data_store(fh)

    @items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        value = ds.read
        interpreter.set_value(target, value)
      end
    end

    interpreter.clear_previous_lines
  end
end

# RECORD
class RecordStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('RECORD')],
      [KeywordToken.new('REC')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    @may_be_if_sub = false

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @read_items, @write_items = tokens_to_expressions(items, :scalar)
      @elements = make_references(@read_items)
      # TODO: merge these two dictionaries
      @elements = make_references(@write_items)
      @mccabe += @write_items.size
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []
    @read_items.each { |item| lines += item.dump }
    @write_items.each { |item| lines += item.dump }
    lines
  end

  def execute_core(interpreter)
    interpreter.set_record_read_variables(@read_items)
    interpreter.set_record_write_variables(@write_items)
  end

  private

  def tokens_to_expressions(tokens_lists, shape)
    read_items = []
    write_items = []

    tokens_lists.each do |tokens_list|
      if tokens_list.class.to_s == 'Array'
        add_target_expression(read_items, tokens_list, shape)
        add_value_expression(write_items, tokens_list, shape)
      end
    end

    [read_items, write_items]
  end

  def add_value_expression(items, tokens, shape)
    items << ValueExpressionSet.new(tokens, shape)
  rescue BASICExpressionError
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" is not a value or operator'
  end

  def add_target_expression(items, tokens, shape)
    items << TargetExpressionSet.new(tokens, shape, false)
  rescue BASICExpressionError
    line_text = tokens.map(&:to_s).join
    @errors << 'Syntax error: "' + line_text + '" is not a value or operator'
  end
end

# RESTORE
class RestoreStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('RESTORE')],
      [KeywordToken.new('RES')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    ds = interpreter.get_data_store(nil)
    ds.reset
  end
end

# RESUME
class ResumeStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('RESUME')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)
    @autonext = false unless @any_if_modifiers

    template_0 = []
    template_1 = [[1, '>=']]

    target = nil
    if check_template(tokens_lists, template_0)
      target = nil
    elsif check_template(tokens_lists, template_1)
      target = tokens_lists[0][0]
    else
      @errors << 'Syntax error'
    end

    @target = nil
    unless target.nil?
      begin
        number = IntegerConstant.new(target)
        @target = LineNumber.new(number)
        @linenums = [@target]
      rescue BASICSyntaxError
        @errors << 'Invalid target'
      end
    end
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    interpreter.resume(@target)
  end
end

# RETURN
class ReturnStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('RETURN')],
      [KeywordToken.new('RET')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)
    @autonext = false unless @any_if_modifiers

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    interpreter.next_line_stmt_mod = interpreter.pop_return
  end
end

# RUN
class RunStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('RUN')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)
    @autonext = false unless @any_if_modifiers

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    interpreter.rerun
  end
end

# SLEEP
class SleepStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('SLEEP')],
      [KeywordToken.new('SLE')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template_0 = []
    template_1 = [[1, '>=']]

    if check_template(tokens_lists, template_0)
      token_list = [NumericConstantToken.new('5')]
      @expression = ValueExpressionSet.new(token_list, :scalar)
      @errors << 'TAB() not allowed' if @expression.has_tab
    elsif check_template(tokens_lists, template_1)
      token_lists = split_tokens(tokens_lists[0], false)
      @expression = ValueExpressionSet.new(token_lists[0], :scalar)
      @errors << 'TAB() not allowed' if @expression.has_tab
      @elements = make_references(nil, @expression)
    else
      @errors << 'Syntax error'
    end

    @errors << 'Too many values' if token_lists.size > 1

    @comprehension_effort += @expression.comprehension_effort
  end

  def uncache_core
    @expression.uncache
  end

  def dump
    lines = @expression.dump

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    values = @expression.evaluate(interpreter)
    value = values[0]
    sleep(value.to_v)
  end
end

# STOP
class StopStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('STOP')],
      [KeywordToken.new('STO')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)
    @autonext = false unless @any_if_modifiers

    template = []

    @errors << 'Syntax error' unless
      check_template(tokens_lists, template)
  end

  def dump
    lines = ['']

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    io = interpreter.console_io
    io.newline_when_needed
    interpreter.stop
  end
end

# UNSAVE
class UnsaveStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('UNSAVE')],
      [KeywordToken.new('UNS')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]
    template_file = ['FILE', [1, '>=']]

    @filenum_expression = []
    if check_template(tokens_lists, template) ||
       check_template(tokens_lists, template_file)
      @filenum_expression = ValueExpressionSet.new(tokens_lists[-1], :scalar)
      @errors << 'TAB() not allowed' if @filenum_expression.has_tab

      @elements = make_references(nil, @filenum_expression)
      @comprehension_effort += @filenum_expression.comprehension_effort
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    @filenum_expression.dump
  end

  def execute_core(interpreter)
    fns = @filenum_expression.evaluate(interpreter)
    fh = FileHandle.new(fns[0])
    # TODO: reset file to zero length
    interpreter.close_file(fh)
  end
end

# WRITE
class WriteStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('WRITE')],
      [KeywordToken.new('WRI')]
    ]
  end

  include FileFunctions
  include WriteFunctions

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :scalar)

      @items.each do |item|
        @errors << 'TAB() not allowed' if item.has_tab
      end

      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    i = 0
    last_was_carriage = true

    while i < @items.size
      item = @items[i]

      # insert an implicit carriage control
      fhr.print_item(',') unless item.carriage_control? || last_was_carriage

      if item.carriage_control?
        item.write(fhr)
      else
        item.write(fhr, interpreter)
      end

      last_was_carriage = item.carriage_control?

      i += 1
    end
  end
end

# ARR FORGET
class ArrForgetStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('FORGET')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      # parse variable
      @variables = []

      tokens_list = split_on_group_separators(tokens_lists[0])
      tokens_list.each do |tokens|
        if tokens[0].variable?
          variable_name = VariableName.new(tokens[0])
          variable = Variable.new(variable_name, :array, [], [])
          @variables << variable
          variablex = XrefEntry.new(variable.to_s, nil, false)
          @elements[:variables] += [variablex]
        else
          @errors << "Invalid variable #{tokens[0]}"
        end
      end
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    @variables.each { |variable| lines << variable.dump }

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    @variables.each { |variable| interpreter.forget_compound_values(variable) }
  end
end

# ARR INPUT
class ArrInputStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('INPUT')]
    ]
  end

  include FileFunctions
  include InputFunctions

  def initialize(_, keywords, tokens_lists)
    super

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :array, true)

      @items.each do |item|
        @errors << 'TAB() not allowed' if item.has_tab
      end

      @file_tokens = extract_file_handle(@items)
      @prompt = extract_prompt(@items)
      @elements = make_references(@items, @file_tokens, @prompt)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :read)

    prompt = nil

    unless @prompt.nil?
      prompts = @prompt.evaluate(interpreter)
      prompt = prompts[0]
    end

    # compute size based on variable dimensions
    # create list of variables with subscripts
    item_names = []

    @items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        name = target.name

        interpreter.set_dimensions(target.name, target.dimensions) if
          target.dimensions?

        raise BASICRuntimeError.new(:te_arr_no_dim) unless
          interpreter.dimensions?(target.name)

        # make sure dimension is one
        dims = interpreter.get_dimensions(name)
        raise(BASICExpressionError, 'Not an array') unless dims.size == 1

        # build names
        base = $options['base'].value
        (base..dims[0].to_i).each do |col|
          coord = AbstractElement.make_coord(col)
          wcoord = interpreter.wrap_subscripts(name, coord)
          variable = Variable.new(name, :array, coord, wcoord)
          item_names << variable
        end
      end
    end

    # get all of the needed values
    if fh.nil?
      # from console
      values = input_values(fhr, interpreter, prompt, item_names.size)
      fhr.implied_newline
    else
      # from file
      values = file_values(fhr, interpreter)
    end

    raise BASICRuntimeError.new(:te_too_few) if values.size < item_names.size

    # use names based on variable dimensions
    name_value_pairs =
      zip(item_names, values[0..item_names.length])

    name_value_pairs.each do |hash|
      variable = hash['name']
      value = hash['value']
      interpreter.set_value(variable, value)
    end

    interpreter.clear_previous_lines
  end
end

# ARR PLOT
class ArrPlotStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('PLOT')]
    ]
  end

  include FileFunctions
  include PrintFunctions

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template2 = [[1, '>=']]

    @items = []

    if check_template(tokens_lists, template2)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions_2(items, :array)
      @file_tokens = extract_file_handle(@items)

      @items.each do |item|
        if item.class.to_s == 'ValueExpressionSet'
          @errors << 'Wrong type' unless
            %i[numeric integer].include?(item.content_type)
        end
      end

      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe = @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    lines += @file_tokens.dump unless @file_tokens.nil?

    @items.each do |item|
      lines += item.dump
    end

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    @items.each do |item|
      if item.carriage_control?
        item.plot(fhr)
      else
        item.plot(fhr, interpreter)
      end
    end
  end
end

# ARR PRINT
class ArrPrintStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('PRINT')]
    ]
  end

  include FileFunctions
  include PrintFunctions

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    # build list: exp, cc, exp, cc, 'USING' exp, cc, exp, cc
    tokens = tokens_lists.flatten
    list = split_keywords(tokens)

    @items = []

    if list.empty?
      expressions = tokens_to_expressions([], :array)
      @items << expressions
    else
      list.each do |item|
        if item.class.to_s == 'Array'
          tokens_lists = split_tokens(item, true)
          expressions = tokens_to_expressions(tokens_lists, :array)
          @items << expressions
        else
          @items << item
        end
      end
    end

    # if list first item is expression
    #   extract possible file handle
    @file_tokens = nil
    unless @items.empty?
      if @items[0].class.to_s == 'Array'
        @file_tokens = extract_file_handle(@items[0]) unless
          @items[0].empty?
      end
    end

    # end with
    #   @file_tokens : exp or nil
    #   @items : list either expression, cc, or keyword

    # if item is keyword then it must be 'USING'
    @items.each do |item|
      unless item.class.to_s == 'Array'
        @errors << 'Syntax error' unless
          item.keyword? && item.to_s == 'USING'
      end
    end

    @elements = make_references(nil, @file_tokens)

    @items.each do |item|
      if item.class.to_s == 'Array'
        elements = make_references(item)
        elements.each { |k, v| @elements[k] += v }
        item.each { |it| @comprehension_effort += it.comprehension_effort }
      elsif item.keyword?
        @comprehension_effort += 1
      end
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    j = 0
    while j < @items.size
      item = @items[j]

      if item.class.to_s == 'Array'
        i = 0
        last_was_carriage = true

        while i < item.size
          it = item[i]

          # insert an implicit carriage control
          fhr.implied unless it.carriage_control? || last_was_carriage

          if it.carriage_control?
            it.print(fhr)
          else
            formats = nil
            it.compound_print(fhr, interpreter, formats)
          end

          last_was_carriage = it.carriage_control?

          i += 1
        end
      else
        # item must be 'USING'
        j += 1

        raise BASICRuntimeError.new(:te_no_fmt) if j >= @items.size

        # extract formats
        item = @items[j]

        format_spec, items = extract_format(item, interpreter)

        raise BASICRuntimeError.new(:te_no_fmt) if format_spec.nil?

        # split format
        formats = split_format(format_spec)

        # check formats wants only one item
        count = 0
        formats.each { |format| count += 1 if format.wants_item }

        raise(BASICSyntaxError, 'Too many fields in USING') unless count <= 1

        raise BASICRuntimeError.new(:te_few_fmt) if items.empty?

        i = 0

        # print variable
        item = items[i]
        item.compound_print(fhr, interpreter, formats)
        last_was_carriage = false

        # if next item is carriage, print it
        i += 1

        if i < items.size && items[i].carriage_control?
          item = items[i]
          item.print(fhr)
          last_was_carriage = true
        end

        i += 1

        while i < items.size
          item = items[i]

          # insert an implicit carriage control
          fhr.implied unless item.carriage_control? || last_was_carriage

          if item.carriage_control?
            item.print(fhr)
          else
            formats = nil
            item.compound_print(fhr, interpreter, formats)
          end

          last_was_carriage = item.carriage_control?

          i += 1
        end
      end

      j += 1
    end
  end
end

# ARR READ
class ArrReadStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('READ')]
    ]
  end

  include FileFunctions
  include ReadFunctions

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions(items, :array, true)

      @items.each do |item|
        @errors << 'TAB() not allowed' if item.has_tab
      end

      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    ds = interpreter.get_data_store(fh)

    @items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        interpreter.set_dimensions(target.name, target.dimensions) if
          target.dimensions?

        raise BASICRuntimeError.new(:te_arr_no_dim) unless
          interpreter.dimensions?(target.name)

        read_values(target.name, interpreter, ds)
      end
    end

    interpreter.clear_previous_lines
  end

  private

  def read_values(name, interpreter, ds)
    dims = interpreter.get_dimensions(name)

    case dims.size
    when 1
      read_array(name, dims, interpreter, ds)
    else
      raise(BASICSyntaxError, 'Dimensions for ARR READ must be 1')
    end
  end

  def read_array(name, dims, interpreter, ds)
    values = {}

    base = $options['base'].value
    (base..dims[0].to_i).each do |col|
      coord = AbstractElement.make_coord(col)
      values[coord] = ds.read
    end

    interpreter.set_values(name, values)
  end
end

# ARR WRITE
class ArrWriteStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR'), KeywordToken.new('WRITE')]
    ]
  end

  include FileFunctions
  include WriteFunctions

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :array)

      @items.each do |item|
        @errors << 'TAB() not allowed' if item.has_tab
      end

      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    i = 0
    last_was_carriage = true

    while i < @items.size
      item = @items[i]

      # insert an implicit carriage control
      fhr.print_item(',') unless item.carriage_control? || last_was_carriage

      if item.carriage_control?
        item.write(fhr)
      else
        item.write(fhr, interpreter)
      end

      last_was_carriage = item.carriage_control?

      i += 1
    end
  end
end

# ARR assignment
class ArrLetStatement < AbstractLetStatement
  def self.lead_keywords
    [
      [KeywordToken.new('ARR')],
      [KeywordToken.new('ARR'), KeywordToken.new('LET')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[3, '>=']]

    if check_template(tokens_lists, template)
      begin
        @assignment = Assignment.new(tokens_lists[0], :array)

        if @assignment.count_target.zero?
          @errors << 'Assignment must have left-hand value(s)'
        end

        if @assignment.count_value.zero?
          @errors << 'Assignment must have right-hand value(s)'
        end

        @errors << 'TAB() not allowed' if @assignment.has_tab

        @warnings << 'Extra values ignored' if
          @assignment.count_value > @assignment.count_target

        @elements = make_references(nil, @assignment)
        @comprehension_effort += @assignment.comprehension_effort
      rescue BASICExpressionError => e
        @errors << e.message
        @assignment = @rest
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    l_values = @assignment.eval_target(interpreter)
    l_value0 = l_values[0]
    l_dims = interpreter.get_dimensions(l_value0.name)

    interpreter.set_default_args('CON1', l_dims)
    interpreter.set_default_args('CON1%', l_dims)
    interpreter.set_default_args('CON1$', l_dims)
    interpreter.set_default_args('RND1', l_dims)
    interpreter.set_default_args('RND1%', l_dims)
    interpreter.set_default_args('RND1$', l_dims)
    interpreter.set_default_args('ZER1', l_dims)
    interpreter.set_default_args('ZER1%', l_dims)
    interpreter.set_default_args('ZER1$', l_dims)

    r_value = first_value(interpreter)

    interpreter.set_default_args('CON1', nil)
    interpreter.set_default_args('CON1%', nil)
    interpreter.set_default_args('CON1$', nil)
    interpreter.set_default_args('RND1', nil)
    interpreter.set_default_args('RND1%', nil)
    interpreter.set_default_args('RND1$', nil)
    interpreter.set_default_args('ZER1', nil)
    interpreter.set_default_args('ZER1%', nil)
    interpreter.set_default_args('ZER1$', nil)

    r_dims = r_value.dimensions

    values = r_value.values_1

    l_values.each do |l_value|
      interpreter.set_dimensions(l_value, r_dims)
      interpreter.set_values(l_value.name, values)
    end
  end

  private

  def first_target(interpreter)
    l_values = @assignment.eval_target(interpreter)

    l_values[0]
  end

  def first_value(interpreter)
    r_values = @assignment.eval_value(interpreter)
    r_value = r_values[0]

    raise(BASICSyntaxError, 'Expected Array') if
      r_value.class.to_s != 'BASICArray'

    r_value
  end
end

# MAT FORGET
class MatForgetStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('FORGET')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      # parse variable
      @variables = []

      tokens_list = split_on_group_separators(tokens_lists[0])
      tokens_list.each do |tokens|
        if tokens[0].variable?
          variable_name = VariableName.new(tokens[0])
          variable = Variable.new(variable_name, :matrix, [], [])
          @variables << variable
          variablex = XrefEntry.new(variable.to_s, nil, false)
          @elements[:variables] += [variablex]
        else
          @errors << "Invalid variable #{tokens[0]}"
        end
      end
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    @variables.each { |variable| lines << variable.dump }

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    @variables.each { |variable| interpreter.forget_compound_values(variable) }
  end
end

# MAT INPUT
class MatInputStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('INPUT')]
    ]
  end

  include FileFunctions
  include InputFunctions

  def initialize(_, keywords, tokens_lists)
    super

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :array, true)

      @items.each do |item|
        @errors << 'TAB() not allowed' if item.has_tab
      end

      @file_tokens = extract_file_handle(@items)
      @prompt = extract_prompt(@items)
      @elements = make_references(@items, @file_tokens, @prompt)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :read)

    prompt = nil

    unless @prompt.nil?
      prompts = @prompt.evaluate(interpreter)
      prompt = prompts[0]
    end

    # compute size based on variable dimensions
    # create list of variables with subscripts
    item_names = []

    @items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        name = target.name

        interpreter.set_dimensions(target.name, target.dimensions) if
          target.dimensions?

        raise BASICRuntimeError.new(:te_mat_no_dim) unless
          interpreter.dimensions?(target.name)

        # make sure dimension is one or two
        dims = interpreter.get_dimensions(name)
        raise(BASICExpressionError, 'Not an array') unless
          dims.size == 1 || dims.size == 2

        # build names
        if dims.size == 1
          base = $options['base'].value
          (base..dims[0].to_i).each do |col|
            coord = AbstractElement.make_coord(col)
            wcoord = interpreter.wrap_subscripts(name, coors)
            variable = Variable.new(name, :matrix, coord, wcoord)
            item_names << variable
          end
        end

        if dims.size == 2
          base = $options['base'].value
          (base..dims[0].to_i).each do |row|
            (base..dims[1].to_i).each do |col|
              coords = AbstractElement.make_coords(row, col)
              wcoords = interpreter.wrap_subscripts(name, coords)
              variable = Variable.new(name, :matrix, coords, wcoords)
              item_names << variable
            end
          end
        end
      end
    end

    # get all of the needed values
    if fh.nil?
      # from console
      values = input_values(fhr, interpreter, prompt, item_names.size)
      fhr.implied_newline
    else
      # from file
      values = file_values(fhr, interpreter)
    end

    raise BASICRuntimeError.new(:te_too_few) if values.size < item_names.size

    # use names based on variable dimensions
    name_value_pairs =
      zip(item_names, values[0..item_names.length])

    name_value_pairs.each do |hash|
      variable = hash['name']
      value = hash['value']
      interpreter.set_value(variable, value)
    end

    interpreter.clear_previous_lines
  end
end

# MAT PLOT
class MatPlotStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('PLOT')]
    ]
  end

  include FileFunctions
  include PrintFunctions

  def initialize(_, keywords, tokens_lists)
    super

    template2 = [[1, '>=']]

    @items = []

    if check_template(tokens_lists, template2)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions_2(items, :matrix)
      @file_tokens = extract_file_handle(@items)

      @items.each do |item|
        if item.class.to_s == 'ValueExpressionSet'
          @errors << 'Wrong type' unless
            %i[numeric integer].include?(item.content_type)
        end
      end

      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe = @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def dump
    lines = []

    lines += @file_tokens.dump unless @file_tokens.nil?

    @items.each do |item|
      lines += item.dump
    end

    @modifiers.each { |item| lines += item.dump } unless @modifiers.nil?

    lines
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    @items.each do |item|
      if item.carriage_control?
        item.plot(fhr)
      else
        item.plot(fhr, interpreter)
      end
    end
  end
end

# MAT PRINT
class MatPrintStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('PRINT')]
    ]
  end

  include FileFunctions
  include PrintFunctions

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    # build list: exp, cc, exp, cc, 'USING' exp, cc, exp, cc
    tokens = tokens_lists.flatten
    list = split_keywords(tokens)

    @items = []

    if list.empty?
      expressions = tokens_to_expressions([], :matrix)
      @items << expressions
    else
      list.each do |item|
        if item.class.to_s == 'Array'
          tokens_lists = split_tokens(item, true)
          expressions = tokens_to_expressions(tokens_lists, :matrix)
          @items << expressions
        else
          @items << item
        end
      end
    end

    # if list first item is expression
    #   extract possible file handle
    @file_tokens = nil
    unless @items.empty?
      if @items[0].class.to_s == 'Array'
        @file_tokens = extract_file_handle(@items[0]) unless
          @items[0].empty?
      end
    end

    # end with
    #   @file_tokens : exp or nil
    #   @items : list either expression, cc, or keyword

    # if item is keyword then it must be 'USING'
    @items.each do |item|
      unless item.class.to_s == 'Array'
        @errors << 'Syntax error' unless
          item.keyword? && item.to_s == 'USING'
      end
    end

    @elements = make_references(nil, @file_tokens)

    @items.each do |item|
      if item.class.to_s == 'Array'
        elements = make_references(item)
        elements.each { |k, v| @elements[k] += v }
        item.each { |it| @comprehension_effort += it.comprehension_effort }
      elsif item.keyword?
        @comprehension_effort += 1
      end
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    j = 0
    while j < @items.size
      item = @items[j]

      if item.class.to_s == 'Array'
        i = 0
        last_was_carriage = true

        while i < item.size
          it = item[i]

          # insert an implicit carriage control
          fhr.implied unless it.carriage_control? || last_was_carriage

          if it.carriage_control?
            # MAT PRINT has different operations for carriage controls
            carriage = map_carriage(it)
            carriage.print(fhr)
          else
            formats = nil
            it.compound_print(fhr, interpreter, formats)
          end

          last_was_carriage = it.carriage_control?

          i += 1
        end
      else
        # item must be 'USING'
        j += 1

        raise BASICRuntimeError.new(:te_no_fmt) if j >= @items.size

        # extract formats
        item = @items[j]

        format_spec, items = extract_format(item, interpreter)

        raise BASICRuntimeError.new(:te_no_fmt) if format_spec.nil?

        # split format
        formats = split_format(format_spec)

        # check formats wants only one item
        count = 0
        formats.each { |format| count += 1 if format.wants_item }

        raise(BASICSyntaxError, 'Too many fields in USING') unless count <= 1

        raise BASICRuntimeError.new(:te_few_fmt) if items.empty?

        i = 0

        # print variable
        item = items[i]
        item.compound_print(fhr, interpreter, formats)
        last_was_carriage = false

        # if next item is carriage, print it
        i += 1

        if i < items.size && items[i].carriage_control?
          item = items[i]
          # MAT PRINT has different operations for carriage controls
          carriage = map_carriage(item)
          carriage.print(fhr)
          last_was_carriage = true
        end

        i += 1

        while i < items.size
          item = items[i]

          # insert an implicit carriage control
          fhr.implied unless item.carriage_control? || last_was_carriage

          if item.carriage_control?
            # MAT PRINT has different operations for carriage controls
            carriage = map_carriage(item)
            carriage.print(fhr)
          else
            formats = nil
            item.compound_print(fhr, interpreter, formats)
          end

          last_was_carriage = item.carriage_control?

          i += 1
        end
      end

      j += 1
    end
  end

  def map_carriage(it)
    carriage = CarriageControl.new('')

    case it.to_s
    when ', '
      # a comma prints a newline
      carriage = CarriageControl.new('NL')
    when '; '
      # a semi does nothing, even after numerics
      carriage = CarriageControl.new('')
    when ''
      # a newline prints a newline (which is normal)
      carriage = it
    when ' '
      # an implied carriage control does nothing
      carriage = CarriageControl.new('')
    end

    carriage
  end
end

# MAT READ
class MatReadStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('READ')]
    ]
  end

  include FileFunctions
  include ReadFunctions

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      items = split_tokens(tokens_lists[0], false)
      @items = tokens_to_expressions(items, :matrix, true)

      @items.each do |item|
        @errors << 'TAB() not allowed' if item.has_tab
      end

      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
      @mccabe += @items.size
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    ds = interpreter.get_data_store(fh)

    @items.each do |item|
      targets = item.evaluate(interpreter)
      targets.each do |target|
        interpreter.set_dimensions(target.name, target.dimensions) if
          target.dimensions?

        raise BASICRuntimeError.new(:te_mat_no_dim) unless
          interpreter.dimensions?(target.name)

        read_values(target.name, interpreter, ds)
      end
    end

    interpreter.clear_previous_lines
  end

  private

  def read_values(name, interpreter, ds)
    dims = interpreter.get_dimensions(name)

    case dims.size
    when 1
      read_vector(name, dims, interpreter, ds)
    when 2
      read_matrix(name, dims, interpreter, ds)
    else
      raise(BASICSyntaxError, 'Dimensions for MAT READ must be 1 or 2')
    end
  end

  def read_vector(name, dims, interpreter, ds)
    values = {}

    base = $options['base'].value

    (base..dims[0].to_i).each do |col|
      coord = AbstractElement.make_coord(col)
      values[coord] = ds.read
    end

    interpreter.set_values(name, values)
  end

  def read_matrix(name, dims, interpreter, ds)
    values = {}

    base = $options['base'].value

    (base..dims[0].to_i).each do |row|
      (base..dims[1].to_i).each do |col|
        coords = AbstractElement.make_coords(row, col)
        values[coords] = ds.read
      end
    end

    interpreter.set_values(name, values)
  end
end

# MAT WRITE
class MatWriteStatement < AbstractStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT'), KeywordToken.new('WRITE')]
    ]
  end

  include FileFunctions
  include WriteFunctions

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[1, '>=']]

    if check_template(tokens_lists, template)
      tokens_lists = split_tokens(tokens_lists[0], true)
      @items = tokens_to_expressions(tokens_lists, :matrix)

      @items.each do |item|
        @errors << 'TAB() not allowed' if item.has_tab
      end

      @file_tokens = extract_file_handle(@items)
      @elements = make_references(@items, @file_tokens)
      @items.each { |item| @comprehension_effort += item.comprehension_effort }
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    fh = get_file_handle(interpreter, @file_tokens)
    fhr = interpreter.get_file_handler(fh, :print)

    i = 0
    last_was_carriage = true

    while i < @items.size
      item = @items[i]

      # insert an implicit carriage control
      fhr.print_item(',') unless item.carriage_control? || last_was_carriage

      if item.carriage_control?
        item.write(fhr)
      else
        item.write(fhr, interpreter)
      end

      last_was_carriage = item.carriage_control?

      i += 1
    end
  end
end

# MAT assignment
class MatLetStatement < AbstractLetStatement
  def self.lead_keywords
    [
      [KeywordToken.new('MAT')],
      [KeywordToken.new('MAT'), KeywordToken.new('LET')]
    ]
  end

  def initialize(_, keywords, tokens_lists)
    super

    extract_modifiers(tokens_lists)

    template = [[3, '>=']]

    if check_template(tokens_lists, template)
      begin
        @assignment = Assignment.new(tokens_lists[0], :matrix)

        if @assignment.count_target.zero?
          @errors << 'Assignment must have left-hand value(s)'
        end

        if @assignment.count_value.zero?
          @errors << 'Assignment must have right-hand value(s)'
        end

        @errors << 'TAB() not allowed' if @assignment.has_tab

        @warnings << 'Extra values ignored' if
          @assignment.count_value > @assignment.count_target

        @elements = make_references(nil, @assignment)
        @comprehension_effort += @assignment.comprehension_effort
      rescue BASICRuntimeError => e
        @errors << e.message
        @assignment = @rest
      end
    else
      @errors << 'Syntax error'
    end
  end

  def execute_core(interpreter)
    l_values = @assignment.eval_target(interpreter)
    l_value0 = l_values[0]
    l_dims = interpreter.get_dimensions(l_value0.name)

    interpreter.set_default_args('CON', l_dims)
    interpreter.set_default_args('CON2', l_dims)
    interpreter.set_default_args('CON2%', l_dims)
    interpreter.set_default_args('CON2$', l_dims)
    interpreter.set_default_args('IDN', l_dims)
    interpreter.set_default_args('RND2', l_dims)
    interpreter.set_default_args('RND2%', l_dims)
    interpreter.set_default_args('RND2$', l_dims)
    interpreter.set_default_args('ZER', l_dims)
    interpreter.set_default_args('ZER2', l_dims)
    interpreter.set_default_args('ZER2%', l_dims)
    interpreter.set_default_args('ZER2$', l_dims)

    r_value = first_value(interpreter)

    interpreter.set_default_args('CON', nil)
    interpreter.set_default_args('CON2', nil)
    interpreter.set_default_args('CON2%', nil)
    interpreter.set_default_args('CON2$', nil)
    interpreter.set_default_args('IDN', nil)
    interpreter.set_default_args('RND2', nil)
    interpreter.set_default_args('RND2%', nil)
    interpreter.set_default_args('RND2$', nil)
    interpreter.set_default_args('ZER', nil)
    interpreter.set_default_args('ZER2', nil)
    interpreter.set_default_args('ZER2%', nil)
    interpreter.set_default_args('ZER2$', nil)

    r_dims = r_value.dimensions

    values = r_value.values_1 if r_dims.size == 1
    values = r_value.values_2 if r_dims.size == 2

    l_values.each do |l_value|
      interpreter.set_dimensions(l_value, r_dims)
      interpreter.set_values(l_value.name, values)
    end
  end

  def first_value(interpreter)
    r_values = @assignment.eval_value(interpreter)
    r_value = r_values[0]

    raise(BASICSyntaxError, 'Expected Matrix') if
      r_value.class.to_s != 'Matrix'

    r_value
  end
end
