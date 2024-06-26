#!/usr/bin/ruby
# frozen_string_literal: true

require 'benchmark'
require 'date'
require 'optparse'
require 'singleton'

require_relative 'exceptions'
require_relative 'tokens'
require_relative 'tokenbuilders'
require_relative 'tokenizers'
require_relative 'constants'
require_relative 'operators'
require_relative 'functions'
require_relative 'expressions'
require_relative 'io'
require_relative 'statements'
require_relative 'modifiers'
require_relative 'interpreter'
require_relative 'program'

# option class
class Option
  attr_reader :types

  def initialize(types, defs, v)
    @types = types
    @defs = defs
    check_value(v)
    @values = [v]
  end

  def set(v)
    num_types = %w[Fixnum Integer]
    v = v != 0 if @defs[:type] == :bool && num_types.include?(v.class.to_s)

    check_value(v)
    @values = [v]
  end

  def value
    @values[-1]
  end

  def push(v)
    num_types = %w[Fixnum Integer]
    v = v != 0 if @defs[:type] == :bool && num_types.include?(v.class.to_s)

    check_value(v)
    @values.push(v)
  end

  def pop
    @values.pop if @values.size > 1
  end

  def to_s
    v = value
    case @defs[:type]
    when :bool
      v.to_s.upcase
    when :int
      v.to_s
    when :float
      v.to_s
    when :string
      "\"#{v}\""
    when :list
      "\"#{v}\""
    end
  end

  private

  def check_value(v)
    check_value_and_type(v)
  rescue BASICSyntaxError => e
    raise e unless @defs.key?(:off) && v == @defs[:off]
  end

  def check_value_and_type(v)
    case @defs[:type]
    when :bool
      legals = %w[TrueClass FalseClass]

      raise(BASICSyntaxError, "Invalid type #{v.class} for boolean") unless
        legals.include?(v.class.to_s)
    when :int
      legals = %w[Fixnum Integer]

      raise(BASICSyntaxError, "Invalid type #{v.class} for integer") unless
        legals.include?(v.class.to_s)

      min = @defs[:min]
      if !min.nil? && v < min
        raise(BASICSyntaxError, "Value #{v} below minimum #{min}")
      end

      max = @defs[:max]
      if !max.nil? && v > max
        raise(BASICSyntaxError, "Value #{v} above maximum #{max}")
      end
    when :float
      legals = %w[Fixnum Integer Float Rational]

      raise(BASICSyntaxError, "Invalid type #{v.class} for float") unless
        legals.include?(v.class.to_s)

      min = @defs[:min]
      if !min.nil? && v < min
        raise(BASICSyntaxError, "Value #{v} below minimum #{min}")
      end

      max = @defs[:max]
      if !max.nil? && v > max
        raise(BASICSyntaxError, "Value #{v} above maximum #{max}")
      end
    when :string
      legals = %(String)

      raise(BASICSyntaxError, "Invalid type #{v.class} for string") unless
        legals.include?(v.class.to_s)
    when :list
      legal_types = %(String)

      raise(BASICSyntaxError, "Invalid type #{v.class} for list") unless
        legal_types.include?(v.class.to_s)

      legal_values = @defs[:values]

      unless legal_values.include?(v.to_s)
        raise(BASICSyntaxError,
              "Invalid value #{v} for list #{legal_values}")
      end
    else
      raise(BASICSyntaxError, 'Unknown value type')
    end
  end
end

# interactive shell
class Shell
  def initialize(console_io, interpreter, tokenbuilders)
    @console_io = console_io
    @interpreter = interpreter
    @tokenbuilders = tokenbuilders
    @invalid_tokenbuilder = InvalidTokenBuilder.new(true, [])
  end

  def run
    need_prompt = true
    @done = false

    until @done
      prompt = $options['prompt'].value

      if need_prompt
        @console_io.print_item(prompt)
        @console_io.newline if prompt.size > 1
      end

      cmd = @console_io.read_line
      need_prompt = process_line_keyboard(cmd)
      need_prompt = true if prompt.size == 1
    end
  end

  private

  def process_line_keyboard(line)
    # starts with a number, so maybe it is a program line
    return @interpreter.program_store_line(line, false, true) if
      /\A[ \t]*\d/ =~ line

    # immediate command -- tokenize and execute
    tokenizer = Tokenizer.new(@tokenbuilders, @invalid_tokenbuilder)
    tokens = tokenizer.tokenize_line(line)
    tokens.delete_if(&:whitespace?)

    process_command_keyboard(tokens, line)
  end

  def process_command_keyboard(tokens, line)
    return false if tokens.empty?

    keyword = tokens[0]
    args = tokens[1..-1]

    if keyword.keyword?
      execute_command(keyword, args)
    else
      @console_io.print_line("Unknown command '#{line}'")
      @console_io.newline
    end
  end

  def process_line_load_command(line)
    return if line.empty?

    # starts with a '.', so is an immediate command
    if line[0] == '.'
      tokenizer = Tokenizer.new(@tokenbuilders, @invalid_tokenbuilder)
      nline = line[1..-1]
      tokens = tokenizer.tokenize_line(nline)
      tokens.delete_if(&:whitespace?)

      process_command_load_command(tokens, line)
      return
    end

    # starts with a number, so maybe it is a program line
    return @interpreter.program_store_line(line, true, true) if
      /\A[ \t]*\d/ =~ line

    # unknown line (probably a continuation of previous line)
    @console_io.print_line("Unknown command '#{line}'")
    @console_io.newline
  end

  def process_command_load_command(tokens, line)
    return false if tokens.empty?

    keyword = tokens[0]
    args = tokens[1..-1]

    if keyword.keyword?
      execute_command_load_command(keyword, args)
    else
      @console_io.print_line("Unknown command '#{line}'")
      @console_io.newline
    end
  end

  def option_command(args, echo_set)
    lines = []

    if args.empty?
      $options.each do |option|
        name = option[0].upcase
        value = option[1].to_s
        lines << ("OPTION #{name} #{value}")
      end
    elsif args.size == 1 && args[0].keyword?
      kwd = args[0].to_s
      kwd_d = kwd.downcase

      raise BASICCommandError, "Unknown option #{kwd}" unless
        $options.key?(kwd_d)

      value = $options[kwd_d].to_s
      lines << ("OPTION #{kwd} #{value}")
    elsif args.size == 2 && args[0].keyword?
      kwd = args[0].to_s
      kwd_d = kwd.downcase

      raise BASICCommandError, "Unknown option #{kwd}" unless
        $options.key?(kwd_d)

      if @interpreter.program_loaded? &&
         !$options[kwd_d].types.include?(:loaded)
        raise BASICCommandError, "Cannot change #{kwd} when program is loaded"
      end

      if args[1].boolean_constant?
        boolean = BooleanValue.new(args[1])
        $options[kwd_d].set(boolean.to_v)
      elsif args[1].numeric_constant?
        numeric = NumericValue.new(args[1])
        $options[kwd_d].set(numeric.to_v)
      elsif args[1].text_constant?
        text = TextValue.new(args[1])
        $options[kwd_d].set(text.to_v)
      else
        raise BASICCommandError, 'Incorrect value type'
      end

      value = $options[kwd_d].to_s
      lines << ("OPTION #{kwd} #{value}") if echo_set
    else
      raise BASICCommandError, 'Too many arguments'
    end

    lines
  end

  def duplicate(o)
    Marshal.load(Marshal.dump(o))
  end

  def execute_command(keyword, args)
    need_prompt = true

    case keyword.to_s
    when 'BYE'
      @done = true
    when 'NEW'
      @interpreter.program_new
      @interpreter.clear_variables
      @interpreter.clear_all_breakpoints
      @console_io.newline
    when 'RUN'
      @interpreter.program_optimize

      if @interpreter.program_okay?
        # duplicate the options
        options2 = {}
        $options.each { |name, option| options2[name] = duplicate(option) }

        timing = Benchmark.measure do
          @interpreter.run
        end

        # restore options to undo any changes during the run
        options2.each { |name, option| $options[name] = option }

        # print timing info
        if $options['timing'].value
          print_timing(timing, @console_io)
          @console_io.newline
        end
      else
        errors = @interpreter.program_errors
        errors.each { |error| @console_io.print_line(error) }
      end
    when 'BKPT'
      texts = @interpreter.set_breakpoints(args)
      texts.each { |text| @console_io.print_line(text) }
    when 'NOBKPT'
      texts = @interpreter.clear_breakpoints(args)
      texts.each { |text| @console_io.print_line(text) }
    when 'LOAD'
      @interpreter.clear_all_breakpoints
      filename, _keywords = parse_args(args)

      raise BASICCommandError, 'Filename not specified' if filename.nil?

      load_file_keyboard(filename)

      errors = @interpreter.program_errors
      errors.each { |error| @console_io.print_line(error) }
      @console_io.newline
    when 'SAVE'
      filename, keywords = parse_args(args)

      raise BASICCommandError, 'Filename not specified' if filename.nil?

      lines = []

      if keywords.include?('OPTION')
        option_lines = option_command([], false)
        option_lines.each do |line|
          lines << (".#{line}")
        end
      end

      lines += @interpreter.program_save

      if keywords.include?('BKPT')
        break_lines = @interpreter.set_breakpoints([])
        break_lines.each do |line|
          lines << (".#{line}")
        end
      end

      save_file(filename, lines)
    when 'LIST'
      texts = @interpreter.program_list(args, false)
      texts.each { |text| @console_io.print_line(text) }

      texts = @interpreter.program_errors
      texts.each { |text| @console_io.print_line(text) }

      @console_io.newline
    when 'PRETTY'
      pretty_multiline = $options['pretty_multiline'].value

      texts = @interpreter.program_pretty(args, pretty_multiline)
      texts.each { |text| @console_io.print_line(text) }

      texts = @interpreter.program_errors
      texts.each { |text| @console_io.print_line(text) }

      @console_io.newline
    when 'DELETE'
      @interpreter.program_delete(args)
    when 'PROFILE'
      show_timing = $options['timing'].value
      texts = @interpreter.program_profile(args, show_timing)
      texts.each { |text| @console_io.print_line(text) }

      texts = @interpreter.program_errors
      texts.each { |text| @console_io.print_line(text) }

      @console_io.newline
    when 'RENUMBER'
      @interpreter.program_optimize

      if @interpreter.program_okay?
        begin
          @interpreter.program_renumber(args)
        rescue BASICCommandError, BASICSyntaxError => e
          @console_io.print_line("Cannot renumber the program: #{e}")
        end
      else
        errors = @interpreter.program_errors
        errors.each { |error| @console_io.print_line(error) }
        @console_io.newline
      end
    when 'CROSSREF'
      @interpreter.program_optimize

      texts = @interpreter.program_crossref
      texts.each { |text| @console_io.print_line(text) }

      @console_io.newline
    when 'DIMS'
      @interpreter.dump_dims
    when 'PARSE'
      texts = @interpreter.program_parse(args)
      texts.each { |text| @console_io.print_line(text) }

      texts = @interpreter.program_errors
      texts.each { |text| @console_io.print_line(text) }

      @console_io.newline
    when 'ANALYZE'
      @interpreter.program_optimize

      texts = @interpreter.program_analyze
      texts.each { |text| @console_io.print_line(text) }

      @console_io.newline
    when 'METRICS'
      @interpreter.program_optimize

      texts = @interpreter.program_metrics
      texts.each { |text| @console_io.print_line(text) }

      @console_io.newline
    when 'TOKENS'
      texts = @interpreter.program_list(args, true)
      texts.each { |text| @console_io.print_line(text) }

      @console_io.newline
    when 'UDFS'
      @interpreter.dump_user_functions
    when 'VARS'
      @interpreter.dump_vars
    when 'OPTION'
      texts = option_command(args, true)
      texts.each { |text| @console_io.print_line(text) }

      @console_io.newline
    else
      @console_io.print_line("Unknown command #{keyword}")
      @console_io.newline
    end

    need_prompt
  rescue BASICCommandError, BASICRuntimeError, BASICSyntaxError => e
    @console_io.print_line(e.to_s)
    @console_io.newline
    true
  end

  def execute_command_load_command(keyword, args)
    need_prompt = true

    case keyword.to_s
    when 'BKPT'
      texts = @interpreter.set_breakpoints(args)
      texts.each { |text| @console_io.print_line(text) }
    when 'OPTION'
      texts = option_command(args, false)
      texts.each { |text| @console_io.print_line(text) }
    else
      @console_io.print_line("Unknown command #{keyword}")
    end

    need_prompt
  rescue BASICCommandError, BASICRuntimeError, BASICSyntaxError => e
    line = "#{keyword} #{args.map(&:to_s).join(' ')}"
    @console_io.print_line(line)
    @console_io.print_line(e.to_s)
    @console_io.newline
    true
  end

  def load_file_keyboard(filename)
    File.open(filename, 'r') do |file|
      @interpreter.program_clear
      file.each_line do |line|
        line = @console_io.ascii_printables(line)
        process_line_load_command(line)
      end
    end
  rescue Errno::ENOENT, Errno::EISDIR
    @console_io.print_line("File '#{filename}' not found")
  end

  def save_file(filename, lines)
    File.open(filename, 'w') do |file|
      lines.each do |line|
        file.puts line
      end
      file.close
    end
  rescue Errno::ENOENT, Errno::EISDIR
    @console_io.print_line("File '#{filename}' not saved")
  end
end

def make_interpreter_tokenbuilders(lead_keywords)
  normal_tb = true
  data_tb = false
  extra_tb = false
  tokenbuilders = []

  tokenbuilders << CommentTokenBuilder.new(normal_tb, '')
  tokenbuilders << RemarkTokenBuilder.new(normal_tb, 'DATA')
  tokenbuilders << StatementSeparatorTokenBuilder.new(normal_tb, '')

  # DATA disables statement keywords
  tokenbuilders << ListTokenBuilder.new(normal_tb, 'DATA', lead_keywords, KeywordToken)

  change_keywords = ChangeStatement.stmt_keywords
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'CHANGE', change_keywords, KeywordToken)
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'CHA', change_keywords, KeywordToken)

  close_keywords = OpenStatement.stmt_keywords
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'CLOSE', close_keywords, KeywordToken)
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'CLO', close_keywords, KeywordToken)
  
  for_keywords = ForStatement.stmt_keywords
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'FOR', for_keywords, KeywordToken)

  goto_keywords = GotoStatement.stmt_keywords
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'GOTO', goto_keywords, KeywordToken)
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'GOT', goto_keywords, KeywordToken)

  if_keywords = ['THEN']
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'IF', if_keywords, KeywordToken)

  then_keywords = ['ELSE']
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'THEN', then_keywords, KeywordToken)

  on_keywords = OnStatement.stmt_keywords
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'ON', on_keywords, KeywordToken)

  open_keywords = OpenStatement.stmt_keywords
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'OPEN', open_keywords, KeywordToken)
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'OPE', open_keywords, KeywordToken)
  
  option_keywords = OptionStatement.stmt_keywords
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'OPTION', option_keywords, KeywordToken)
  
  print_keywords = PrintStatement.stmt_keywords
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'PRINT', print_keywords, KeywordToken)
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'PRI', print_keywords, KeywordToken)
  tokenbuilders << ListTokenBuilder.new(extra_tb, '&', print_keywords, KeywordToken)
  
  colon_file = $options['colon_file'].value
  un_ops = UnaryOperator.operators(colon_file)
  tokenbuilders << ListTokenBuilder.new(normal_tb, '', un_ops, OperatorToken)

  min_max_op = $options['min_max_op'].value
  bi_ops = BinaryOperator.operators(min_max_op)
  tokenbuilders << ListTokenBuilder.new(normal_tb, 'DATA', bi_ops, OperatorToken)

  tokenbuilders << BreakTokenBuilder.new(normal_tb, '')

  if $options['brackets'].value
    tokenbuilders << ListTokenBuilder.new(normal_tb, 'DATA', ['(', '['], GroupStartToken)
    tokenbuilders << ListTokenBuilder.new(normal_tb, 'DATA', [')', ']'], GroupEndToken)
  else
    tokenbuilders << ListTokenBuilder.new(normal_tb, 'DATA', ['('], GroupStartToken)
    tokenbuilders << ListTokenBuilder.new(normal_tb, 'DATA', [')'], GroupEndToken)
  end

  tokenbuilders << ListTokenBuilder.new(normal_tb, '', [',', ';'], ParamSeparatorToken)

  function_names = FunctionFactory.function_names
  tokenbuilders <<
    ListTokenBuilder.new(normal_tb, 'DATA', function_names, FunctionToken)

  user_function_names = FunctionFactory.user_function_names
  tokenbuilders <<
    ListTokenBuilder.new(normal_tb, 'DATA', user_function_names, UserFunctionToken)

  tokenbuilders << QuotedTextTokenBuilder.new(normal_tb, '')
  tokenbuilders << NumberTokenBuilder.new(normal_tb, '')

  allow_hash_constant = $options['allow_hash_constant'].value
  tokenbuilders << HashNumberTokenBuilder.new(normal_tb, '', allow_hash_constant)

  tokenbuilders << IntegerTokenBuilder.new(normal_tb, '')
  tokenbuilders << NumericSymbolTokenBuilder.new(normal_tb, '')

  allow_ascii = $options['allow_ascii'].value
  tokenbuilders << TextSymbolTokenBuilder.new(normal_tb, '') if allow_ascii

  tokenbuilders << VariableTokenBuilder.new(normal_tb, 'DATA')
  tokenbuilders << ListTokenBuilder.new(normal_tb, '', %w[TRUE FALSE], BooleanLiteralToken)
  tokenbuilders << BareTextTokenBuilder.new(data_tb, 'DATA')
  tokenbuilders << WhitespaceTokenBuilder.new(normal_tb, '')
end

def make_command_tokenbuilders()
  command_tb = true
  extra_tb = false
  tokenbuilders = []

  keywords = %w[
    ANALYZE BKPT NOBKPT BYE CROSSREF DELETE DIMS IF LIST LOAD METRICS
    NEW OPTION PARSE PRETTY PROFILE RENUMBER RUN SAVE TOKENS UDFS VARS
  ]
  tokenbuilders << ListTokenBuilder.new(command_tb, '', keywords, KeywordToken)

  option_keywords = OptionStatement.cmd_keywords
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'OPTION', option_keywords, KeywordToken)

  print_keywords = PrintStatement.stmt_keywords
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'PRINT', print_keywords, KeywordToken)
  tokenbuilders << ListTokenBuilder.new(extra_tb, 'PRI', print_keywords, KeywordToken)
  tokenbuilders << ListTokenBuilder.new(extra_tb, '&', print_keywords, KeywordToken)
  
  colon_file = $options['colon_file'].value
  un_ops = UnaryOperator.operators(colon_file)
  tokenbuilders << ListTokenBuilder.new(command_tb, '', un_ops, OperatorToken)

  min_max_op = $options['min_max_op'].value
  bi_ops = BinaryOperator.operators(min_max_op)
  tokenbuilders << ListTokenBuilder.new(command_tb, '', bi_ops, OperatorToken)

  tokenbuilders << BreakTokenBuilder.new(command_tb, '')

  tokenbuilders << ListTokenBuilder.new(command_tb, '', ['('], GroupStartToken)
  tokenbuilders << ListTokenBuilder.new(command_tb, '', [')'], GroupEndToken)
  tokenbuilders << ListTokenBuilder.new(command_tb, '', [',', ';'], ParamSeparatorToken)

  function_names = FunctionFactory.function_names
  tokenbuilders <<
    ListTokenBuilder.new(command_tb, '', function_names, FunctionToken)

  user_function_names = FunctionFactory.user_function_names
  tokenbuilders <<
    ListTokenBuilder.new(command_tb, '', user_function_names, UserFunctionToken)

  tokenbuilders << QuotedTextTokenBuilder.new(command_tb, '')
  tokenbuilders << NumberTokenBuilder.new(command_tb, '')

  allow_hash_constant = $options['allow_hash_constant'].value
  tokenbuilders << HashNumberTokenBuilder.new(command_tb, '', allow_hash_constant)

  tokenbuilders << VariableTokenBuilder.new(command_tb, '')
  tokenbuilders << ListTokenBuilder.new(command_tb, '', %w[TRUE FALSE], BooleanLiteralToken)
  tokenbuilders << WhitespaceTokenBuilder.new(command_tb, '')
end

def print_timing(timing, console_io)
  user_time = timing.utime + timing.cutime
  sys_time = timing.stime + timing.cstime
  console_io.print_line('CPU time:')
  console_io.print_line(" user: #{user_time.round(2)}")
  console_io.print_line(" system: #{sys_time.round(2)}")
end

def parse_args(tokens)
  filename = nil
  keywords = []

  tokens.each do |token|
    keywords << token if token.keyword?
    filename = token.value.strip if token.text_constant? && filename.nil?
  end

  [filename, keywords]
end

def load_file_command_line(filename, interpreter, console_io)
  File.open(filename, 'r') do |file|
    interpreter.program_clear
    file.each_line do |line|
      line = console_io.ascii_printables(line)
      interpreter.program_store_line(line, false, false)
    end
  end
rescue Errno::ENOENT, Errno::EISDIR
  console_io.print_line("File '#{filename}' not found")
  false
end

options = {}
OptionParser.new do |opt|
  opt.on('-l', '--list SOURCE') { |o| options[:list_name] = o }
  opt.on('--tokens') { |o| options[:tokens] = o }
  opt.on('-p', '--pretty SOURCE') { |o| options[:pretty_name] = o }
  opt.on('--pretty-multiline') { |o| options[:pretty_multiline] = o }
  opt.on('-r', '--run SOURCE') { |o| options[:run_name] = o }
  opt.on('--profile') { |o| options[:profile] = o }
  opt.on('-c', '--crossref SOURCE') { |o| options[:cref_name] = o }
  opt.on('--parse SOURCE') { |o| options[:parse_name] = o }
  opt.on('--analyze SOURCE') { |o| options[:analyze_name] = o }
  opt.on('--metrics SOURCE') { |o| options[:metrics_name] = o }

  opt.on('--apostrophe-comment') { |o| options[:apostrophe_comment] = o }
  opt.on('--asc-allow-all') { |o| options[:asc_allow_all] = o }
  opt.on('--back-tab') { |o| options[:back_tab] = o }
  opt.on('--bang-comment') { |o| options[:bang_comment] = o }
  opt.on('--base BASE') { |o| options[:base] = o }
  opt.on('--brackets') { |o| options[:brackets] = o }
  opt.on('--no-cache-const-expr') { |o| options[:no_cache_const_expr] = o }
  opt.on('--chr-allow-all') { |o| options[:chr_allow_all] = o }
  opt.on('--colon-file') { |o| options[:colon_file] = o }
  opt.on('--no-colon-separator') { |o| options[:no_colon_sep] = o }
  opt.on('--crlf-on-line-input') { |o| options[:crlf_on_line_input] = o }
  opt.on('--define-ascii') { |o| options[:allow_ascii] = o }

  opt.on('--no-detect-infinite-loop') do |o|
    options[:no_detect_infinite_loop] = o
  end

  opt.on('--extend-if') { |o| options[:extend_if] = o }
  opt.on('--field-sep-semi') { |o| options[:field_sep_semi] = o }
  opt.on('--forget-fornext') { |o| options[:forget_fornext] = o }
  opt.on('--fornext-one-beyond') { |o| options[:fornext_one_beyond] = o }
  opt.on('--hash-constant') { |o| options[:hash_constant] = o }
  opt.on('--no-heading') { |o| options[:no_heading] = o }
  opt.on('--ignore-randomize') { |o| options[:ignore_randomize] = o }
  opt.on('--ignore-rnd-arg') { |o| options[:ignore_rnd_arg] = o }
  opt.on('--implied-semicolon') { |o| options[:implied_semicolon] = o }
  opt.on('--input-high-bit') { |o| options[:input_high_bit] = o }
  opt.on('--int-bitwise') { |o| options[:int_bitwise] = o }
  opt.on('--int-floor') { |o| options[:int_floor] = o }
  opt.on('--lock-fornext') { |o| options[:lock_fornext] = o }
  opt.on('--match-fornext') { |o| options[:match_fornext] = o }
  opt.on('--max-dim LIMIT') { |o| options[:max_dim] = o }
  opt.on('--min-max-op') { |o| options[:min_max_op] = o }
  opt.on('--precision DIGITS') { |o| options[:precision] = o }
  opt.on('--print-width WIDTH') { |o| options[:print_width] = o }
  opt.on('--prompt PROMPT') { |o| options[:prompt] = o }
  opt.on('--prompt-count') { |o| options[:prompt_count] = o }
  opt.on('--promptd PROMPT') { |o| options[:promptd] = o }
  opt.on('--provenance') { |o| options[:provenance] = o }
  opt.on('--qmark-after-prompt') { |o| options[:qmark_after_prompt] = o }
  opt.on('--randomize') { |o| options[:randomize] = o }
  opt.on('--require-initialized') { |o| options[:require_initialized] = o }

  opt.on('--semicolon-zone-width WIDTH') do |o|
    options[:semicolon_zone_width] = o
  end

  opt.on('--single-quote-strings') { |o| options[:single_quote_strings] = o }
  opt.on('--no-timing') { |o| options[:no_timing] = o }
  opt.on('--trace') { |o| options[:trace] = o }
  opt.on('--trig-require-units') { |o| options[:trig_require_units] = o }
  opt.on('--tty') { |o| options[:tty] = o }
  opt.on('--tty-lf') { |o| options[:tty_lf] = o }
  opt.on('--warn-fornext-length LENGTH') { |o| options[:warn_fornext_length] = o }
  opt.on('--warn-fornext-level LEVEL') { |o| options[:warn_fornext_level] = o }
  opt.on('--warn-gosub-length LENGTH') { |o| options[:warn_gosub_length] = o }
  opt.on('--warn-list-width WIDTH') { |o| options[:warn_list_width] = o }
  opt.on('--warn-pretty-width WIDTH') { |o| options[:warn_pretty_width] = o }
  opt.on('--wrap') { |o| options[:wrap] = o }
  opt.on('--zone-width WIDTH') { |o| options[:zone_width] = o }
end.parse!

list_filename = options[:list_name]
list_tokens = options.key?(:tokens)
pretty_filename = options[:pretty_name]
parse_filename = options[:parse_name]
analyze_filename = options[:analyze_name]
metrics_filename = options[:metrics_name]
run_filename = options[:run_name]
cref_filename = options[:cref_name]
show_profile = options.key?(:profile)

boolean = { type: :bool }
string = { type: :string }
int = { type: :int, min: 0 }
int1to17 = { type: :int, max: 17, min: 1, off: 'INFINITE' }
int132 = { type: :int, max: 132, min: 0 }
int40 = { type: :int, max: 40, min: 0 }
int1 = { type: :int, max: 1, min: 0 }
int32767 = { type: :int, max: 32_767, min: 999 }
separator = { type: :list, values: %w[COMMA SEMI NL NONE] }

all_types = %i[new loaded runtime]
loaded = %i[new loaded]
only_new = %i[new]

$options = {}

$options['allow_ascii'] =
  Option.new(all_types, boolean, options.key?(:allow_ascii))

$options['allow_hash_constant'] =
  Option.new(only_new, boolean, options.key?(:hash_constant))

$options['apostrophe_comment'] =
  Option.new(only_new, boolean, options.key?(:apostrophe_comment))

$options['asc_allow_all'] =
  Option.new(all_types, boolean, options.key?(:asc_allow_all))

$options['back_tab'] = Option.new(all_types, boolean, options.key?(:back_tab))
$options['backslash_separator'] = Option.new(only_new, boolean, true)

$options['bang_comment'] =
  Option.new(only_new, boolean, options.key?(:bang_comment))

base = 0
base = options[:base].to_i if options.key?(:base)
$options['base'] = Option.new(all_types, int1, base)

$options['brackets'] = Option.new(only_new, boolean, options.key?(:brackets))

$options['cache_const_expr'] =
  Option.new(all_types, boolean, !options.key?(:no_cache_const_expr))

$options['chr_allow_all'] =
  Option.new(all_types, boolean, options.key?(:chr_allow_all))

$options['colon_file'] =
  Option.new(only_new, boolean, options.key?(:colon_file))

colon_separator = !options.key?(:no_colon_sep) && !options.key?(:colon_file)
$options['colon_separator'] = Option.new(only_new, boolean, colon_separator)

$options['crlf_on_line_input'] =
  Option.new(all_types, boolean, options.key?(:crlf_on_line_input))

$options['default_prompt'] = Option.new(all_types, string, '? ')

$options['degrees'] = Option.new(all_types, string, 'DEG')

$options['detect_infinite_loop'] =
  Option.new(all_types, boolean, !options.key?(:no_detect_infinite_loop))

$options['extend_if'] = Option.new(only_new, boolean, options.key?(:extend_if))

field_sep = Option.new(all_types, separator, 'COMMA')
field_sep = Option.new(all_types, separator, 'SEMI') if
  options.key?(:field_sep_semi)
$options['field_sep'] = field_sep

$options['forget_fornext'] =
  Option.new(all_types, boolean, options.key?(:forget_fornext))

$options['fornext_one_beyond'] =
  Option.new(all_types, boolean, options.key?(:fornext_one_beyond))

$options['heading'] =
  Option.new(all_types, boolean, !options.key?(:no_heading))

$options['ignore_rnd_arg'] =
  Option.new(all_types, boolean, options.key?(:ignore_rnd_arg))

$options['implied_semicolon'] =
  Option.new(all_types, boolean, options.key?(:implied_semicolon))

$options['input_high_bit'] =
  Option.new(all_types, boolean, options.key?(:input_high_bit))

$options['int_bitwise'] =
  Option.new(only_new, boolean, options.key?(:int_bitwise))

$options['int_floor'] =
  Option.new(all_types, boolean, options.key?(:int_floor))

$options['lock_fornext'] =
  Option.new(all_types, boolean, options.key?(:lock_fornext))

$options['match_fornext'] =
  Option.new(all_types, boolean, options.key?(:match_fornext))

max_dim = 100
max_dim = options[:max_dim].to_i if options.key?(:max_dim)
$options['max_dim'] = Option.new(all_types, int, max_dim)

$options['max_line_num'] = Option.new(only_new, int32767, 32_767)
$options['min_line_num'] = Option.new(only_new, int1, 1)

$options['min_max_op'] =
  Option.new(only_new, boolean, options.key?(:min_max_op))

newline_speed = 0
newline_speed = 10 if options.key?(:tty_lf)
$options['newline_speed'] = Option.new(all_types, int, newline_speed)

precision = 9
if options.key?(:precision)
  precision = options[:precision]
  precision = precision.to_i if precision =~ /\A\d+\z/
end
$options['precision'] = Option.new(all_types, int1to17, precision)

$options['pretty_multiline'] =
  Option.new(loaded, boolean, options.key?(:pretty_multiline))

print_speed = 0
print_speed = 10 if options.key?(:tty)
$options['print_speed'] = Option.new(all_types, int, print_speed)

print_width = 72
print_width = options[:print_width].to_i if options.key?(:print_width)
$options['print_width'] = Option.new(all_types, int132, print_width)

$options['prompt'] = Option.new(loaded, string, 'READY')
if options.key?(:prompt)
  prompt = options[:prompt]
  $options['prompt'] = Option.new(loaded, string, prompt)
end

$options['promptd'] = Option.new(loaded, string, 'DEBUG')
if options.key?(:promptd)
  promptd = options[:promptd]
  $options['promptd'] = Option.new(loaded, string, promptd)
end

$options['prompt_count'] =
  Option.new(all_types, boolean, options.key?(:prompt_count))

$options['provenance'] =
  Option.new(all_types, boolean, options.key?(:provenance))

$options['qmark_after_prompt'] =
  Option.new(all_types, boolean, options.key?(:qmark_after_prompt))

$options['radians'] = Option.new(all_types, string, 'RAD')

$options['randomize'] =
  Option.new(all_types, boolean, options.key?(:randomize))

$options['require_initialized'] =
  Option.new(all_types, boolean, options.key?(:require_initialized))

$options['respect_randomize'] =
  Option.new(all_types, boolean, !options.key?(:ignore_randomize))

semicolon_zone_width = 0
if options.key?(:semicolon_zone_width)
  semicolon_zone_width = options[:semicolon_zone_width].to_i
end

$options['semicolon_zone_width'] =
  Option.new(all_types, int, semicolon_zone_width)

$options['single_quote_strings'] =
  Option.new(only_new, boolean, options.key?(:single_quote_strings))

$options['timing'] = Option.new(all_types, boolean, !options.key?(:no_timing))
$options['trace'] = Option.new(all_types, boolean, options.key?(:trace))

$options['trig_require_units'] =
  Option.new(all_types, boolean, options.key?(:trig_require_units))

warn_fornext_length = 40
if options.key?(:warn_fornext_length)
  warn_fornext_length = options[:warn_fornext_length].to_i
end
$options['warn_fornext_length'] = Option.new(loaded, int, warn_fornext_length)

warn_fornext_level = 3
if options.key?(:warn_fornext_level)
  warn_fornext_level = options[:warn_fornext_level].to_i
end
$options['warn_fornext_level'] = Option.new(loaded, int, warn_fornext_level)

warn_gosub_length = 40
if options.key?(:warn_gosub_length)
  warn_gosub_length = options[:warn_gosub_length].to_i
end
$options['warn_gosub_length'] = Option.new(loaded, int, warn_gosub_length)

warn_list_width = 72
if options.key?(:warn_list_width)
  warn_list_width = options[:warn_list_width].to_i
end
$options['warn_list_width'] = Option.new(loaded, int132, warn_list_width)

warn_pretty_width = 72
if options.key?(:warn_pretty_width)
  warn_pretty_width = options[:warn_pretty_width].to_i
end
$options['warn_pretty_width'] = Option.new(loaded, int132, warn_pretty_width)

$options['wrap'] = Option.new(all_types, boolean, options.key?(:wrap))

zone_width = 16
zone_width = options[:zone_width].to_i if options.key?(:zone_width)
$options['zone_width'] = Option.new(all_types, int40, zone_width)

console_io = ConsoleIo.new

statement_factory = StatementFactory.instance
lead_keywords = statement_factory.lead_keywords
tokenbuilders = make_interpreter_tokenbuilders(lead_keywords)
statement_factory.tokenbuilders = tokenbuilders

interpreter = Interpreter.new(console_io)
interpreter.set_default_args('RND', NumericValue.new(1))
interpreter.set_default_args('RND%', IntegerValue.new(100))
interpreter.set_default_args('RND$', NumericValue.new(6))
program = Program.new(console_io, statement_factory)
interpreter.program = program

if $options['heading'].value
  console_io.print_line('BASIC-1973 interpreter version -1')
  console_io.newline
end

# list the source
unless list_filename.nil?
  args = [TextValue.new(list_filename)]

  filename, _keywords = parse_args(args)

  begin
    if load_file_command_line(filename, interpreter, console_io)
      interpreter.program_optimize

      texts = interpreter.program_list('', list_tokens)
    else
      texts = interpreter.program_errors
    end
    texts.each { |text| console_io.print_line(text) }

    console_io.newline
  rescue BASICSyntaxError => e
    console_io.print_line(e.to_s)
  end
end

# show parse dump
unless parse_filename.nil?
  args = [TextValue.new(parse_filename)]

  filename, _keywords = parse_args(args)

  begin
    if load_file_command_line(filename, interpreter, console_io)
      interpreter.program_optimize

      texts = interpreter.program_parse('')
    else
      texts = interpreter.program_errors
    end
    texts.each { |text| console_io.print_line(text) }

    console_io.newline
  rescue BASICSyntaxError => e
    console_io.print_line(e.to_s)
  end
end

# show analysis
unless analyze_filename.nil?
  args = [TextValue.new(analyze_filename)]

  filename, _keywords = parse_args(args)

  begin
    if load_file_command_line(filename, interpreter, console_io)
      interpreter.program_optimize

      texts = interpreter.program_analyze
      texts.each { |text| console_io.print_line(text) }
    end

    console_io.newline
  rescue BASICSyntaxError => e
    console_io.print_line(e.to_s)
  end
end

# show metrics
unless metrics_filename.nil?
  token = BareTextLiteralToken.new(metrics_filename)
  args = [TextValue.new(token)]

  filename, _keywords = parse_args(args)

  begin
    if load_file_command_line(filename, interpreter, console_io)
      interpreter.program_optimize

      texts = interpreter.program_metrics
      texts.each { |text| console_io.print_line(text) }
    end

    console_io.newline
  rescue BASICSyntaxError => e
    console_io.print_line(e.to_s)
  end
end

# pretty-print the source
unless pretty_filename.nil?
  args = [TextValue.new(pretty_filename)]

  filename, _keywords = parse_args(args)

  begin
    if load_file_command_line(filename, interpreter, console_io)
      interpreter.program_optimize

      pretty_multiline = $options['pretty_multiline'].value
      texts = interpreter.program_pretty('', pretty_multiline)
      texts.each { |text| console_io.print_line(text) }
    end

    console_io.newline
  rescue BASICSyntaxError => e
    console_io.print_line(e.to_s)
  end
end

# cross-reference the source
unless cref_filename.nil?
  args = [TextValue.new(cref_filename)]

  filename, _keywords = parse_args(args)

  begin
    if load_file_command_line(filename, interpreter, console_io)
      interpreter.program_optimize
      texts = interpreter.program_crossref
      texts.each { |text| console_io.print_line(text) }
    end

    console_io.newline
  rescue BASICSyntaxError => e
    console_io.print_line(e.to_s)
  end
end

# run the source
unless run_filename.nil?
  args = [TextValue.new(run_filename)]

  filename, _keywords = parse_args(args)

  begin
    if load_file_command_line(filename, interpreter, console_io)
      interpreter.program_optimize

      if interpreter.program_okay?
        begin
          timing = Benchmark.measure do
            interpreter.run
            console_io.newline
          end

          show_timing = $options['timing'].value
          if show_timing
            print_timing(timing, console_io)
            console_io.newline
          end

          if show_profile
            texts = interpreter.program_profile('', show_timing)
            texts.each { |text| console_io.print_line(text) }
            console_io.newline
          end
        rescue BASICCommandError => e
          console_io.print_line(e.to_s)
        end
      else
        errors = interpreter.program_errors
        errors.each { |error| console_io.print_line(error) }
      end
    end
  rescue BASICSyntaxError => e
    console_io.print_line(e.to_s)
  end
end

# no command-line directives, so run BASIC shell
if list_filename.nil? && parse_filename.nil? && analyze_filename.nil? &&
   metrics_filename.nil? && pretty_filename.nil? && cref_filename.nil? &&
   run_filename.nil?

  tokenbuilders = make_command_tokenbuilders

  shell = Shell.new(console_io, interpreter, tokenbuilders)
  shell.run
end

if $options['heading'].value
  console_io.print_line('BASIC-1973 ended')
  console_io.newline
end
