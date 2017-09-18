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

# Contain line numbers
class LineNumber
  attr_reader :line_number

  def self.init?(text)
    /\A\d+\z/.match(text)
  end

  def initialize(line_number)
    raise BASICException, "Invalid line number '#{line_number}'" unless
      line_number.class.to_s == 'NumericConstantToken'

    @line_number = line_number.to_i
  end

  def eql?(other)
    @line_number == other.line_number
  end

  def ==(other)
    @line_number == other.line_number
  end

  def hash
    @line_number.hash
  end

  def succ
    LineNumber.new(@line_number + 1)
  end

  def <=>(other)
    @line_number <=> other.line_number
  end

  def >(other)
    @line_number > other.line_number
  end

  def >=(other)
    @line_number >= other.line_number
  end

  def <(other)
    @line_number < other.line_number
  end

  def <=(other)
    @line_number <= other.line_number
  end

  def to_s
    @line_number.to_s
  end
end

# line number range, in form start-end
class LineNumberRange
  attr_reader :list

  def self.init?(text)
    /\A\d+-\d+\z/.match(text)
  end

  def initialize(spec, program_line_numbers)
    raise(BASICException, 'Invalid list specification') unless
      LineNumberRange.init?(spec)
    parts = spec.split('-')
    start_val = LineNumber.new(NumericConstantToken.new(parts[0]))
    end_val = LineNumber.new(NumericConstantToken.new(parts[1]))
    @list = []
    program_line_numbers.each do |line_number|
      @list << line_number if line_number >= start_val && line_number <= end_val
    end
  end
end

# line number range, in form start-count (count default is 20)
class LineNumberCountRange
  attr_reader :list

  def self.init?(text)
    /\A\d+\+\d+\z/.match(text) || /\A\d+\+\z/.match(text)
  end

  def initialize(spec, program_line_numbers)
    raise(BASICException, 'Invalid list specification') unless
      LineNumberCountRange.init?(spec)

    parts = spec.split('+')
    start_val = LineNumber.new(NumericConstantToken.new(parts[0]))
    count = parts.size > 1 ? parts[1].to_i : 20
    make_list(program_line_numbers, start_val, count)
  end

  private

  def make_list(program_line_numbers, start_val, count)
    @list = []
    program_line_numbers.each do |line_number|
      if line_number >= start_val && count >= 0
        @list << line_number
        count -= 1
      end
    end
  end
end

# Contain line number ranges
# used in LIST and DELETE commands
class LineListSpec
  attr_reader :line_numbers
  attr_reader :range_type

  def initialize(text, program_line_numbers)
    @line_numbers = []
    @range_type = :empty
    if text == ''
      @line_numbers = program_line_numbers
      @range_type = :all
    elsif LineNumber.init?(text)
      make_single(text, program_line_numbers)
    elsif LineNumberRange.init?(text)
      make_range(text, program_line_numbers)
    elsif LineNumberCountRange.init?(text)
      make_count_range(text, program_line_numbers)
    else
      raise(BASICException, 'Invalid list specification')
    end
  end

  private

  def make_single(text, program_line_numbers)
    line_number = LineNumber.new(NumericConstantToken.new(text))
    @line_numbers << line_number if
      program_line_numbers.include?(line_number)
    @range_type = :single
  end

  def make_range(text, program_line_numbers)
    range = LineNumberRange.new(text, program_line_numbers)
    @line_numbers = range.list
    @range_type = :range
  end

  def make_count_range(text, program_line_numbers)
    range = LineNumberCountRange.new(text, program_line_numbers)
    @line_numbers = range.list
    @range_type = :range
  end
end

# LineNumberIndex class to hold line number and index within line
class LineNumberIndex
  attr_reader :number
  attr_reader :statement
  attr_reader :index

  def initialize(number, statement, index)
    @number = number
    @statement = statement
    @index = index
  end

  def to_s
    return @number.to_s if @statement.zero? && @index.zero?
    return @number.to_s + '.' + @statement.to_s if @index.zero?
    @number.to_s + '.' + @statement.to_s + '.' + @index.to_s
  end
end

# Line class to hold a line of code
class Line
  attr_reader :statements
  attr_reader :tokens

  def initialize(text, statements, tokens, comment)
    @text = text
    @statements = statements
    @tokens = tokens
    @comment = comment
  end

  def list
    @text
  end

  def pretty(multiline)
    if multiline
      pretty_lines = AbstractToken.pretty_multiline([], @tokens)
    else
      pretty_lines = AbstractToken.pretty_tokens([], @tokens)
    end
    unless @comment.nil?
      line_0 = pretty_lines[0]
      space = @text.size - (line_0.size + @comment.to_s.size)
      space = 5 if space < 5
      line_0 += ' ' * space
      line_0 += @comment.to_s
      pretty_lines[0] = line_0
    end
    pretty_lines
  end

  def profile
    texts = []
    @statements.each { |statement| texts << statement.profile }
  end

  def renumber(renumber_map)
    tokens = []
    separator = StatementSeparatorToken.new('\\')
    @statements.each do |statement|
      statement.renumber(renumber_map)
      tokens << statement.keywords
      tokens << statement.tokens
      tokens << separator
    end
    tokens.pop
    text = AbstractToken.pretty_tokens([], tokens.flatten)
    Line.new(text, @statements, tokens.flatten, @comment)
  end

  def check(program, console_io, line_number)
    retval = true
    index = 0
    @statements.each do |statement|
      line_number_index = LineNumberIndex.new(line_number, index, 0)
      r = statement.program_check(program, console_io, line_number_index)
      retval &&= r
      index += 1
    end
    retval
  end
end

# interactive shell
class Shell
  def initialize(console_io, interpreter, program)
    @console_io = console_io
    @interpreter = interpreter
    @program = program
  end

  def run
    need_prompt = true
    done = false
    until done
      @console_io.print_line('READY') if need_prompt
      cmd = @console_io.read_line
      if /\A\d/ =~ cmd
        # starts with a number, so maybe it is a program line
        need_prompt = @program.store_program_line(cmd, true)
      else
        # immediate command -- execute
        done = execute_command(cmd)
        need_prompt = true
      end
    end
  end

  private

  def execute_command(cmd)
    return false if cmd.empty?
    return true if cmd == 'EXIT'
    cmd4 = cmd[0..3]
    cmd6 = cmd[0..5]
    cmd7 = cmd[0..6]
    cmd8 = cmd[0..7]
    if simple_command?(cmd)
      execute_simple_command(cmd)
    elsif command_4?(cmd4)
      execute_4_command(cmd4, cmd[4..-1])
    elsif command_6?(cmd6)
      execute_6_command(cmd6, cmd[6..-1])
    elsif command_7?(cmd7)
      execute_7_command(cmd7, cmd[7..-1])
    elsif command_8?(cmd8)
      execute_8_command(cmd8, cmd[8..-1])
    else
      print "Unknown command #{cmd}\n"
    end
    false
  end

  def simple_command?(text)
    %w(NEW RUN TRACE .VARS .UDFS .DIMS).include?(text)
  end

  def execute_simple_command(text)
    case text
    when 'NEW'
      @program.cmd_new
      @interpreter.clear_variables
    when 'RUN'
      cmd_run(false, true)
    when 'TRACE'
      cmd_run(true, false)
    when '.VARS'
      dump_vars
    when '.UDFS'
      dump_user_functions
    when '.DIMS'
      dump_dims
    end
  end

  def command_4?(text)
    %w(LIST LOAD SAVE).include?(text)
  end

  def execute_4_command(cmd, rest)
    case cmd
    when 'LIST'
      @program.list(rest, false)
    when 'LOAD'
      @program.load(rest)
    when 'SAVE'
      @program.save(rest)
    end
  end

  def command_6?(text)
    %w(TOKENS PRETTY DELETE).include?(text)
  end

  def execute_6_command(cmd, rest)
    case cmd
    when 'TOKENS'
      @program.list(rest, true)
    when 'PRETTY'
      @program.pretty(rest)
    when 'DELETE'
      @program.delete(rest)
    end
  end

  def command_7?(text)
    %w(PROFILE).include?(text)
  end

  def execute_7_command(cmd, rest)
    case cmd
    when 'PROFILE'
      @program.profile(rest)
    end
  end

  def command_8?(text)
    %w(RENUMBER).include?(text)
  end

  def execute_8_command(cmd, _)
    case cmd
    when 'RENUMBER'
      @program.renumber if @program.check
    end
  end

  def cmd_run(trace_flag, show_timing)
    if @program.empty?
      @console_io.print_line('No program loaded')
    else
      @interpreter.run(@program, trace_flag, show_timing) if @program.check
    end
  end

  def dump_vars
    @interpreter.dump_vars
  end

  def dump_user_functions
    @interpreter.dump_user_functions
  end

  def dump_dims
    @interpreter.dump_dims
  end
end

def make_tokenizers(statement_separators, comment_leads, allow_hash_constant,
                    min_max_op, colon_file)
  tokenizers = []

  tokenizers << CommentTokenBuilder.new(comment_leads)
  tokenizers << RemarkTokenBuilder.new

  unless statement_separators.empty?
    tokenizers <<
      ListTokenBuilder.new(statement_separators, StatementSeparatorToken)
  end

  statement_factory = StatementFactory.instance
  keywords = statement_factory.keywords_definitions

  tokenizers << ListTokenBuilder.new(keywords, KeywordToken)

  un_ops = UnaryOperator.operators(colon_file)
  bi_ops = BinaryOperator.operators(min_max_op)
  operators = (un_ops + bi_ops).uniq
  tokenizers << ListTokenBuilder.new(operators, OperatorToken)

  tokenizers << BreakTokenBuilder.new

  tokenizers << ListTokenBuilder.new(['(', '['], GroupStartToken)
  tokenizers << ListTokenBuilder.new([')', ']'], GroupEndToken)
  tokenizers << ListTokenBuilder.new([',', ';'], ParamSeparatorToken)

  tokenizers <<
    ListTokenBuilder.new(FunctionFactory.function_names, FunctionToken)

  function_names = ('FNA'..'FNZ').to_a
  tokenizers << ListTokenBuilder.new(function_names, UserFunctionToken)

  tokenizers << TextTokenBuilder.new
  tokenizers << NumberTokenBuilder.new(allow_hash_constant)
  tokenizers << IntegerTokenBuilder.new
  tokenizers << VariableTokenBuilder.new

  tokenizers <<
    ListTokenBuilder.new(%w(TRUE FALSE), BooleanConstantToken)

  tokenizers << WhitespaceTokenBuilder.new
end

options = {}
OptionParser.new do |opt|
  opt.on('-l', '--list SOURCE') { |o| options[:list_name] = o }
  opt.on('--tokens') { |o| options[:tokens] = o }
  opt.on('-p', '--pretty SOURCE') { |o| options[:pretty_name] = o }
  opt.on('-r', '--run SOURCE') { |o| options[:run_name] = o }
  opt.on('--pretty-multiline') { |o| options[:pretty_multiline] = o }
  opt.on('--profile') { |o| options[:profile] = o }
  opt.on('--no-heading') { |o| options[:no_heading] = o }
  opt.on('--echo-input') { |o| options[:echo_input] = o }
  opt.on('--trace') { |o| options[:trace] = o }
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
  opt.on('--fornext-one-beyond' ) { |o| options[:fornext_one_beyond] = o }
  opt.on('--require-initialized') { |o| options[:require_initialized] = o }
  opt.on('--hash-constant') { |o| options[:hash_constant] = o }
  opt.on('--min-max-op') { |o| options[:min_max_op] = o }
end.parse!

list_filename = options[:list_name]
list_tokens = options.key?(:tokens)
pretty_filename = options[:pretty_name]
pretty_multiline = options.key?(:pretty_multiline)
run_filename = options[:run_name]
show_profile = options.key?(:profile)
show_heading = !options.key?(:no_heading)
echo_input = options.key?(:echo_input)
trace_flag = options.key?(:trace)
show_timing = !options.key?(:no_timing)
output_speed = 0
output_speed = 10 if options.key?(:tty)
newline_speed = 0
newline_speed = 10 if options.key?(:tty_lf)
input_high_bit = options.key?(:input_high_bit)
colon_separator = !options.key?(:no_colon_sep)
colon_file = options.key?(:colon_file)
colon_separator = false if colon_file
backslash_separator = true
apostrophe_comment = true
bang_comment = options.key?(:bang_comment)
print_width = 72
print_width = options[:print_width].to_i if options.key?(:print_width)
zone_width = 16
zone_width = options[:zone_width].to_i if options.key?(:zone_width)
back_tab = options.key?(:back_tab)
int_floor = options.key?(:int_floor)
ignore_rnd_arg = options.key?(:ignore_rnd_arg)
implied_semicolon = options.key?(:implied_semicolon)
qmark_after_prompt = options.key?(:qmark_after_prompt)
randomize = options.key?(:randomize)
respect_randomize = true
respect_randomize = !options[:ignore_randomize] if
  options.key?(:ignore_randomize)
if_false_next_line = options.key?(:if_false_next_line)
fornext_one_beyond = options.key?(:fornext_one_beyond)
require_initialized = options.key?(:require_initialized)
statement_seps = []
statement_seps << '\\' if backslash_separator
statement_seps << ':' if colon_separator
comment_leads = []
comment_leads << "'" if apostrophe_comment
comment_leads << '!' if bang_comment
allow_hash_constant = options.key?(:hash_constant)
min_max_op = options.key?(:min_max_op)

default_prompt = TextConstantToken.new('"? "')
console_io =
  ConsoleIo.new(print_width, zone_width, back_tab, output_speed,
                newline_speed, implied_semicolon, default_prompt,
                qmark_after_prompt, echo_input, input_high_bit)

tokenizers = make_tokenizers(statement_seps, comment_leads, allow_hash_constant,
                             min_max_op, colon_file)

if show_heading
  console_io.print_line('BASIC-1973 interpreter version -1')
  console_io.newline
end

program = Program.new(console_io, tokenizers, pretty_multiline)

if !run_filename.nil?
  if program.load(run_filename) && program.check
    interpreter =
      Interpreter.new(console_io, int_floor, ignore_rnd_arg, randomize,
                      respect_randomize, if_false_next_line,
                      fornext_one_beyond, require_initialized)
    interpreter.run(program, trace_flag, show_timing)
  end
elsif !list_filename.nil?
  program.list('', list_tokens) if program.load(list_filename)
elsif !pretty_filename.nil?
  program.pretty('') if program.load(pretty_filename)
else
  interpreter =
    Interpreter.new(console_io, int_floor, ignore_rnd_arg, randomize,
                    respect_randomize, if_false_next_line,
                    fornext_one_beyond, require_initialized)
  shell = Shell.new(console_io, interpreter, program)
  shell.run
end

if show_heading
  console_io.newline
  console_io.print_line('BASIC-1973 ended')
end
