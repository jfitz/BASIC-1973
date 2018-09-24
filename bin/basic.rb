#!/usr/bin/ruby

require 'benchmark'
require 'optparse'
require 'singleton'
require 'io/console'

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

# interactive shell
class Shell
  def initialize(console_io, interpreter, program, action_flags,
                 tokenbuilders)

    @console_io = console_io
    @interpreter = interpreter
    @program = program
    @action_flags = action_flags
    @tokenbuilders = tokenbuilders
    @invalid_tokenbuilder = InvalidTokenBuilder.new
  end

  def run
    need_prompt = true
    @done = false
    until @done
      @console_io.print_line('READY') if need_prompt
      cmd = @console_io.read_line
      need_prompt = process_line(cmd)
    end
  end

  private

  def process_line(line)
    # starts with a number, so maybe it is a program line
    return @program.store_program_line(line, true) if /\A\d/ =~ line

    # immediate command -- tokenize and execute
    tokenizer = Tokenizer.new(@tokenbuilders, @invalid_tokenbuilder)
    tokens = tokenizer.tokenize(line)
    tokens.delete_if(&:whitespace?)

    process_command(tokens, line)
  end

  def process_command(tokens, line)
    return false if tokens.empty?

    keyword = tokens[0]
    args = tokens[1..-1]

    if keyword.keyword?
      execute_command(keyword, args)
    else
      print "Unknown command '#{line}'\n"
    end
  end

  def option_command(args)
    @action_flags.each do |option|
      name = option[0].upcase
      value = option[1].to_s.upcase
      @console_io.print_line(name + ' ' + value)
    end
  end

  def execute_command(keyword, args)
    need_prompt = true

    case keyword.to_s
    when 'EXIT'
      @done = true
    when 'NEW'
      @program.cmd_new
      @interpreter.clear_variables
      @interpreter.clear_breakpoints
    when 'RUN'
      if @program.check
        timing = Benchmark.measure {
          @program.run(@interpreter, @action_flags)
        }
        print_timing(timing, @console_io) if @action_flags['timing']
      end
    when 'BREAK'
      @interpreter.set_breakpoints(args)
    when 'TRACE'
      old_trace_flag = @action_flags['trace']
      @action_flags['trace'] = true
      @program.run(@interpreter, @action_flags) if @program.check
      @action_flags['trace'] = old_trace_flag
    when 'LOAD'
      @interpreter.clear_breakpoints
      @program.load(args)
    when 'SAVE'
      @program.save(args)
    when 'LIST'
      @program.list(args, false)
    when 'PRETTY'
      pretty_multiline = @action_flags['pretty_multiline']
      @program.pretty(args, pretty_multiline)
    when 'DELETE'
      @program.delete(args)
    when 'PROFILE'
      @program.profile(args)
    when 'RENUMBER'
      if @program.check
        renumber_map = @program.renumber
        @interpreter.renumber_breakpoints(renumber_map)
      end
    when 'CROSSREF'
      @program.crossref if @program.check
    when 'DIMS'
      @interpreter.dump_dims
    when 'PARSE'
      @program.parse(args)
    when 'TOKENS'
      @program.list(args, true)
    when 'UDFS'
      @interpreter.dump_user_functions
    when 'VARS'
      @interpreter.dump_vars
    when 'OPTION'
      option_command(args)
    else
      print "Unknown command #{keyword}\n"
    end

    need_prompt
  rescue BASICCommandError => e
    @console_io.print_line(e.to_s)
    true
  end
end

def make_interpreter_tokenbuilders(token_flags, quotes, statement_separators,
                                   comment_leads)
  tokenbuilders = []

  tokenbuilders << CommentTokenBuilder.new(comment_leads)
  tokenbuilders << RemarkTokenBuilder.new

  unless statement_separators.empty?
    tokenbuilders <<
      ListTokenBuilder.new(statement_separators, StatementSeparatorToken)
  end

  statement_factory = StatementFactory.instance
  keywords = statement_factory.keywords_definitions
  tokenbuilders << ListTokenBuilder.new(keywords, KeywordToken)

  colon_file = token_flags['colon_file']
  un_ops = UnaryOperator.operators(colon_file)
  min_max_op = token_flags['min_max_op']
  bi_ops = BinaryOperator.operators(min_max_op)
  operators = (un_ops + bi_ops).uniq
  tokenbuilders << ListTokenBuilder.new(operators, OperatorToken)

  tokenbuilders << BreakTokenBuilder.new

  tokenbuilders << ListTokenBuilder.new(['(', '['], GroupStartToken)
  tokenbuilders << ListTokenBuilder.new([')', ']'], GroupEndToken)
  tokenbuilders << ListTokenBuilder.new([',', ';'], ParamSeparatorToken)

  tokenbuilders <<
    ListTokenBuilder.new(FunctionFactory.function_names, FunctionToken)

  tokenbuilders <<
    ListTokenBuilder.new(FunctionFactory.user_function_names, UserFunctionToken)

  tokenbuilders << TextTokenBuilder.new(quotes)
  allow_hash_constant = token_flags['allow_hash_constant']
  tokenbuilders << NumberTokenBuilder.new(allow_hash_constant)
  tokenbuilders << IntegerTokenBuilder.new
  allow_pi = token_flags['allow_pi']
  tokenbuilders << NumericSymbolTokenBuilder.new if allow_pi
  allow_ascii = token_flags['allow_ascii']
  tokenbuilders << TextSymbolTokenBuilder.new if allow_ascii
  tokenbuilders << VariableTokenBuilder.new

  tokenbuilders <<
    ListTokenBuilder.new(%w(TRUE FALSE), BooleanConstantToken)

  tokenbuilders << WhitespaceTokenBuilder.new
end

def make_command_tokenbuilders(token_flags, quotes)
  tokenbuilders = []

  keywords = %w(
    BREAK CROSSREF DELETE DIMS EXIT LIST LOAD NEW OPTION PARSE PRETTY
    PROFILE RENUMBER RUN SAVE TRACE TOKENS UDFS VARS
  )
  tokenbuilders << ListTokenBuilder.new(keywords, KeywordToken)

  colon_file = token_flags['colon_file']
  un_ops = UnaryOperator.operators(colon_file)
  min_max_op = token_flags['min_max_op']
  bi_ops = BinaryOperator.operators(min_max_op)
  operators = (un_ops + bi_ops).uniq
  tokenbuilders << ListTokenBuilder.new(operators, OperatorToken)

  tokenbuilders << ListTokenBuilder.new([',', ';'], ParamSeparatorToken)

  tokenbuilders << TextTokenBuilder.new(quotes)

  allow_hash_constant = token_flags['allow_hash_constant']
  tokenbuilders << NumberTokenBuilder.new(allow_hash_constant)

  tokenbuilders << WhitespaceTokenBuilder.new
end

def print_timing(timing, console_io)
  user_time = timing.utime + timing.cutime
  sys_time = timing.stime + timing.cstime
  console_io.newline
  console_io.print_line('CPU time:')
  console_io.print_line(" user: #{user_time.round(2)}")
  console_io.print_line(" system: #{sys_time.round(2)}")
  console_io.newline
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
  opt.on('--no-heading') { |o| options[:no_heading] = o }
  opt.on('--echo-input') { |o| options[:echo_input] = o }
  opt.on('--trace') { |o| options[:trace] = o }
  opt.on('--provenence') { |o| options[:provenence] = o }
  opt.on('--no-timing') { |o| options[:no_timing] = o }
  opt.on('--tty') { |o| options[:tty] = o }
  opt.on('--tty-lf') { |o| options[:tty_lf] = o }
  opt.on('--input-high-bit') { |o| options[:input_high_bit] = o }
  opt.on('--no-colon-separator') { |o| options[:no_colon_sep] = o }
  opt.on('--colon-file') { |o| options[:colon_file] = o }
  opt.on('--bang-comment') { |o| options[:bang_comment] = o }
  opt.on('--print-width WIDTH') { |o| options[:print_width] = o }
  opt.on('--zone-width WIDTH') { |o| options[:zone_width] = o }
  opt.on('--back-tab') { |o| options[:back_tab] = o }
  opt.on('--int-floor') { |o| options[:int_floor] = o }
  opt.on('--ignore-rnd-arg') { |o| options[:ignore_rnd_arg] = o }
  opt.on('--implied-semicolon') { |o| options[:implied_semicolon] = o }
  opt.on('--qmark-after-prompt') { |o| options[:qmark_after_prompt] = o }
  opt.on('--randomize') { |o| options[:randomize] = o }
  opt.on('--ignore-randomize') { |o| options[:ignore_randomize] = o }
  opt.on('--if-false-next-line') { |o| options[:if_false_next_line] = o }
  opt.on('--fornext-one-beyond') { |o| options[:fornext_one_beyond] = o }
  opt.on('--lock-fornext') { |o| options[:lock_fornext] = o }
  opt.on('--require-initialized') { |o| options[:require_initialized] = o }
  opt.on('--hash-constant') { |o| options[:hash_constant] = o }
  opt.on('--define-pi') { |o| options[:allow_pi] = o }
  opt.on('--define-ascii') { |o| options[:allow_ascii] = o }
  opt.on('--min-max-op') { |o| options[:min_max_op] = o }
  opt.on('--asc-allow-all') { |o| options[:asc_allow_all] = o }
  opt.on('--chr-allow-all') { |o| options[:chr_allow_all] = o }
  opt.on('--single-quote-strings') { |o| options[:single_quote_strings] = o }
  opt.on('--crlf-on-line-input') { |o| options[:crlf_on_line_input] = o }
end.parse!

list_filename = options[:list_name]
list_tokens = options.key?(:tokens)
pretty_filename = options[:pretty_name]
parse_filename = options[:parse_name]
run_filename = options[:run_name]
cref_filename = options[:cref_name]
show_profile = options.key?(:profile)

action_flags = {}
action_flags['trace'] = options.key?(:trace)
action_flags['provenence'] = options.key?(:provenence)
action_flags['pretty_multiline'] = options.key?(:pretty_multiline)
action_flags['timing'] = !options.key?(:no_timing)
action_flags['heading'] = !options.key?(:no_heading)

output_flags = {}
output_flags['echo'] = options.key?(:echo_input)
output_flags['speed'] = 0
output_flags['speed'] = 10 if options.key?(:tty)
output_flags['newline_speed'] = 0
output_flags['newline_speed'] = 10 if options.key?(:tty_lf)
output_flags['print_width'] = 72
output_flags['print_width'] = options[:print_width].to_i if
  options.key?(:print_width)
output_flags['zone_width'] = 16
output_flags['zone_width'] = options[:zone_width].to_i if
  options.key?(:zone_width)
output_flags['implied_semicolon'] = options.key?(:implied_semicolon)
output_flags['qmark_after_prompt'] = options.key?(:qmark_after_prompt)
output_flags['default_prompt'] = TextConstantToken.new('"? "')
output_flags['back_tab'] = options.key?(:back_tab)
output_flags['input_high_bit'] = options.key?(:input_high_bit)
output_flags['crlf_on_line_input'] = options.key?(:crlf_on_line_input)

interpreter_flags = {}
interpreter_flags['int_floor'] = options.key?(:int_floor)
interpreter_flags['ignore_rnd_arg'] = options.key?(:ignore_rnd_arg)
interpreter_flags['randomize'] = options.key?(:randomize)
interpreter_flags['lock_fornext'] = options.key?(:lock_fornext)
interpreter_flags['respect_randomize'] = !options.key?(:ignore_randomize)
interpreter_flags['if_false_next_line'] = options.key?(:if_false_next_line)
interpreter_flags['fornext_one_beyond'] = options.key?(:fornext_one_beyond)
interpreter_flags['require_initialized'] = options.key?(:require_initialized)
interpreter_flags['asc_allow_all'] = options.key?(:asc_allow_all)
interpreter_flags['chr_allow_all'] = options.key?(:chr_allow_all)

token_flags = {}
token_flags['colon_separator'] = !options.key?(:no_colon_sep)
token_flags['colon_file'] = options.key?(:colon_file)
token_flags['colon_separator'] = false if token_flags['colon_file']
token_flags['backslash_separator'] = true
token_flags['apostrophe_comment'] = true
token_flags['bang_comment'] = options.key?(:bang_comment)
token_flags['single_quote_strings'] = options.key?(:single_quote_strings)
token_flags['allow_hash_constant'] = options.key?(:hash_constant)
token_flags['allow_pi'] = options.key?(:allow_pi)
token_flags['allow_ascii'] = options.key?(:allow_ascii)
token_flags['min_max_op'] = options.key?(:min_max_op)

statement_seps = []
statement_seps << '\\' if token_flags['backslash_separator']
statement_seps << ':' if token_flags['colon_separator']
quotes = []
quotes << '"'
quotes << "'" if token_flags['single_quote_strings']
comment_leads = []
comment_leads << '!' if token_flags['bang_comment']

comment_leads << "'" if
  token_flags['apostrophe_comment'] && !token_flags['single_quote_strings']

console_io =
  ConsoleIo.new(output_flags)

tokenbuilders =
  make_interpreter_tokenbuilders(token_flags, quotes, statement_seps,
                                 comment_leads)

if action_flags['heading']
  console_io.print_line('BASIC-1973 interpreter version -1')
  console_io.newline
end

program = Program.new(console_io, tokenbuilders)

if !run_filename.nil?
  token = TextConstantToken.new('"' + run_filename + '"')
  nametokens = [TextConstant.new(token)]
  if program.load(nametokens) && program.check
    interpreter = Interpreter.new(console_io, interpreter_flags)
    interpreter.set_default_args('RND', NumericConstant.new(1))

    timing = Benchmark.measure {
      program.run(interpreter, action_flags)
    }

    print_timing(timing, console_io) if action_flags['timing']
    program.profile('') if show_profile
  end
elsif !list_filename.nil?
  token = TextConstantToken.new('"' + list_filename + '"')
  nametokens = [TextConstant.new(token)]
  if program.load(nametokens)
    program.list('', list_tokens)
  end
elsif !parse_filename.nil?
  token = TextConstantToken.new('"' + parse_filename + '"')
  nametokens = [TextConstant.new(token)]
  if program.load(nametokens)
    program.parse('')
  end
elsif !pretty_filename.nil?
  token = TextConstantToken.new('"' + pretty_filename + '"')
  nametokens = [TextConstant.new(token)]
  if program.load(nametokens)
    pretty_multiline = action_flags['pretty_multiline']
    program.pretty('', pretty_multiline)
  end
elsif !cref_filename.nil?
  token = TextConstantToken.new('"' + cref_filename + '"')
  nametokens = [TextConstant.new(token)]
  if program.load(nametokens)
    program.crossref
  end
else
  interpreter = Interpreter.new(console_io, interpreter_flags)
  interpreter.set_default_args('RND', NumericConstant.new(1))

  tokenbuilders = make_command_tokenbuilders(token_flags, quotes)

  shell =
    Shell.new(console_io, interpreter, program, action_flags,
              tokenbuilders)

  shell.run
end

if action_flags['heading']
  console_io.newline
  console_io.print_line('BASIC-1973 ended')
end
