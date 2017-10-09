# line reference for cross reference
class LineRef
  def initialize(line_num, assignment)
    @line_num = line_num
    @assignment = assignment
  end

  def to_s
    if @assignment
      @line_num.to_s + '='
    else
      @line_num.to_s
    end
  end
end

# program container
class Program
  def initialize(console_io, tokenbuilders, pretty_multiline)
    @console_io = console_io
    @program_lines = {}
    @statement_factory = StatementFactory.instance
    @statement_factory.tokenbuilders = tokenbuilders
    @pretty_multiline = pretty_multiline
  end

  def empty?
    @program_lines.empty?
  end

  def line_number?(line_number)
    @program_lines.key?(line_number)
  end

  def lines
    @program_lines
  end

  def cmd_new
    @program_lines = {}
  end

  def line_list_spec(linespec)
    linespec = linespec.strip
    line_numbers = @program_lines.keys.sort
    LineListSpec.new(linespec, line_numbers)
  end

  def list(line_number_range, list_tokens)
    if !@program_lines.empty?
      line_numbers = line_number_range.line_numbers
      list_lines_errors(line_numbers, list_tokens)
    else
      @console_io.print_line('No program loaded')
    end
  end

  def pretty(line_number_range)
    if !@program_lines.empty?
      line_numbers = line_number_range.line_numbers
      pretty_lines_errors(line_numbers)
    else
      @console_io.print_line('No program loaded')
    end
  end

  def profile(line_number_range)
    if !@program_lines.empty?
      line_numbers = line_number_range.line_numbers
      profile_lines_errors(line_numbers)
    else
      @console_io.print_line('No program loaded')
    end
  end

  def load(filename)
    filename = filename.strip
    if !filename.empty?
      begin
        File.open(filename, 'r') do |file|
          @program_lines = {}
          file.each_line do |line|
            line = @console_io.ascii_printables(line)
            store_program_line(line, false)
          end
        end
        true
      rescue Errno::ENOENT
        @console_io.print_line("File '#{filename}' not found")
        false
      end
    else
      @console_io.print_line('Filename not specified')
      false
    end
  end

  def save(filename)
    if @program_lines.empty?
      @console_io.print_line('No program loaded')
    else
      filename = filename.strip
      if filename.empty?
        @console_io.print_line('Filename not specified')
      else
        save_file(filename)
      end
    end
  end

  def save_file(filename)
    line_numbers = @program_lines.keys.sort
    begin
      File.open(filename, 'w') do |file|
        line_numbers.each do |line_num|
          line = @program_lines[line_num]
          statements = line.statements
          text = statements.join('\\')
          file.puts line_num + ' ' + text
        end
        file.close
      end
    rescue Errno::ENOENT
      @console_io.print_line("File '#{filename}' not opened")
    end
  end

  def print_profile
    @program_lines.keys.sort.each do |line_number|
      line = @program_lines[line_number]
      number = line_number.to_s
      statements = line.statements
      statement_index = 0
      statements.each do |statement|
        profile = statement.profile
        text = number.to_s + '.' + statement_index.to_s + profile
        puts text
        statement_index += 1
      end
    end
  end

  def delete(line_number_range)
    if @program_lines.empty?
      @console_io.print_line('No program loaded')
    else
      delete_lines(line_number_range)
    end
  end

  def delete_lines(line_number_range)
    case line_number_range.range_type
    when :single
      line_numbers = line_number_range.line_numbers
      delete_specific_lines(line_numbers)
    when :range
      line_numbers = line_number_range.line_numbers
      list_and_delete_lines(line_numbers)
    when :all
      @console_io.print_line('Type NEW to delete an entire program')
    end
  end

  # generate new line numbers
  def renumber
    renumber_map = {}
    new_number = 10
    @program_lines.keys.sort.each do |line_number|
      number_token = NumericConstantToken.new(new_number)
      new_line_number = LineNumber.new(number_token)
      renumber_map[line_number] = new_line_number
      new_number += 10
    end
    # assign new line numbers
    new_program_lines = {}
    @program_lines.keys.sort.each do |line_number|
      line = @program_lines[line_number]
      new_line_number = renumber_map[line_number]
      new_program_lines[new_line_number] = line.renumber(renumber_map)
    end

    @program_lines = new_program_lines
  end

  def numeric_refs
    refs = {}
    @program_lines.keys.sort.each do |line_number|
      line = @program_lines[line_number]
      statements = line.statements

      rs = []
      statements.each do |statement|
        rs += statement.numerics
      end
      refs[line_number] = rs
    end
    refs
  end

  def strings_refs
    refs = {}
    @program_lines.keys.sort.each do |line_number|
      line = @program_lines[line_number]
      statements = line.statements

      rs = []
      statements.each do |statement|
        rs += statement.strings
      end
      refs[line_number] = rs
    end
    refs
  end

  def function_refs
    refs = {}
    @program_lines.keys.sort.each do |line_number|
      line = @program_lines[line_number]
      statements = line.statements

      rs = []
      statements.each do |statement|
        rs = statement.functions
      end
      refs[line_number] = rs
    end
    refs
  end

  def user_function_refs
    refs = {}
    @program_lines.keys.sort.each do |line_number|
      line = @program_lines[line_number]
      statements = line.statements

      rs = []
      statements.each do |statement|
        rs += statement.userfuncs
      end
      refs[line_number] = rs
    end
    refs
  end

  def variables_refs
    refs = {}
    @program_lines.keys.sort.each do |line_number|
      line = @program_lines[line_number]
      statements = line.statements

      rs = []
      statements.each do |statement|
        rs = statement.variables
      end
      refs[line_number] = rs
    end
    refs
  end

  def print_refs(title, refs)
    puts title
    refs.keys.sort.each do |line_number|
      lines = refs[line_number]
      puts line_number.to_s + ":\t" + lines.map(&:to_s).uniq.join(', ')
    end
    puts ''
  end

  # generate cross-reference list
  def crossref
    puts 'Cross reference'
    puts ''

    nums_list = numeric_refs
    numerics = make_summary(nums_list)
    print_refs('Numeric constants', numerics)

    strs_list = strings_refs
    strings = make_summary(strs_list)
    print_refs('String constants', strings)

    funcs_list = function_refs
    functions = make_summary(funcs_list)
    print_refs('Functions', functions)

    udfs_list = user_function_refs
    userfuncs = make_summary(udfs_list)
    print_refs('User-defined functions', userfuncs)

    vars_list = variables_refs
    variables = make_summary(vars_list)
    print_refs('Variables', variables)
  end

  def make_summary(list)
    summary = {}
    list.each do |line_number, refs|
      line_ref = LineRef.new(line_number, false)
      refs.each do |ref|
        entries = summary.key?(ref) ? summary[ref] : []
        entries << line_ref
        summary[ref] = entries
      end
    end
    summary
  end

  def store_program_line(cmd, print_errors)
    line_num, line = parse_line(cmd)
    if !line_num.nil? && !line.nil?
      check_line_duplicate(line_num, print_errors)
      check_line_sequence(line_num, print_errors)
      @program_lines[line_num] = line
      statements = line.statements
      any_errors = false
      statements.each do |statement|
        statement.errors.each { |error| puts error } if print_errors
        any_errors |= !statement.errors.empty?
      end
      any_errors
    else
      true
    end
  end

  def parse_line(line)
    @statement_factory.parse(line)
  rescue BASICException => e
    @console_io.print_line("Syntax error: #{e.message}")
  end

  def check_line_duplicate(line_num, print_errors)
    # warn about duplicate lines when loading
    # but not when typing
    @console_io.print_line("Duplicate line number #{line_num}") if
      @program_lines.key?(line_num) && !print_errors
  end

  def check_line_sequence(line_num, print_errors)
    # warn about lines out of sequence
    # but not when typing
    @console_io.print_line("Line #{line_num} is out of sequence") if
      !@program_lines.empty? &&
      line_num < @program_lines.max[0] &&
      !print_errors
  end

  def list_lines_errors(line_numbers, list_tokens)
    line_numbers.each do |line_number|
      line = @program_lines[line_number]
      @console_io.print_line(line_number.to_s + line.list)
      statements = line.statements
      statements.each do |statement|
        statement.errors.each { |error| puts ' ' + error }
      end
      tokens = line.tokens
      text_tokens = tokens.map(&:to_s)
      @console_io.print_line('TOKENS: ' + text_tokens.to_s) if list_tokens
    end
  end

  def pretty_lines_errors(line_numbers)
    line_numbers.each do |line_number|
      line = @program_lines[line_number]
      number = line_number.to_s
      pretty_lines = line.pretty(@pretty_multiline)
      pretty_lines.each do |pretty_line|
        @console_io.print_line(number + pretty_line)
        number = ' ' * number.size
      end
      statements = line.statements
      statements.each do |statement|
        statement.errors.each { |error| puts ' ' + error }
      end
    end
  end

  def profile_lines_errors(line_numbers)
    line_numbers.each do |line_number|
      line = @program_lines[line_number]
      number = line_number.to_s
      statements = line.statements
      statement_index = 0
      statements.each do |statement|
        profile = statement.profile
        @console_io.print_line(number + '.' + statement_index.to_s + profile)
        statement_index += 1
      end
    end
  end

  def list_lines(line_numbers)
    line_numbers.each do |line_number|
      line = @program_lines[line_number]
      text = line.list
      @console_io.print_line(line_number.to_s + text)
    end
  end

  def delete_specific_lines(line_numbers)
    line_numbers.each { |line_number| @program_lines.delete(line_number) }
  end

  def list_and_delete_lines(line_numbers)
    list_lines(line_numbers)
    print 'DELETE THESE LINES? '
    answer = @console_io.read_line
    delete_specific_lines(line_numbers) if answer == 'YES'
  end

  def check
    result = true
    @program_lines.keys.sort.each do |line_number|
      r = @program_lines[line_number].check(self, @console_io, line_number)
      result &&= r
    end
    result
  end

  def find_next_line_index(current_line_index)
    # find next index with current statement
    line_number = current_line_index.number
    line = @program_lines[line_number]

    statements = line.statements
    statement_index = current_line_index.statement
    statement = statements[statement_index]

    index = current_line_index.index
    if index < statement.last_index
      index += 1
      return LineNumberIndex.new(line_number, statement_index, index)
    end

    # find next statement within the current line
    if statement_index < statements.size - 1
      statement_index += 1
      statement = statements[statement_index]
      index = statement.start_index
      return LineNumberIndex.new(line_number, statement_index, index)
    end

    # find the next line
    line_numbers = @program_lines.keys.sort
    line_number = current_line_index.number
    index = line_numbers.index(line_number)
    line_number = line_numbers[index + 1]
    unless line_number.nil?
      line = @program_lines[line_number]
      statements = line.statements
      statement = statements[0]
      index = statement.start_index
      return LineNumberIndex.new(line_number, 0, index)
    end

    # nothing left to execute
    nil
  end

  def find_next_line(current_line_index)
    # find next numbered statement
    line_numbers = @program_lines.keys.sort
    line_number = current_line_index.number
    index = line_numbers.index(line_number)
    line_number = line_numbers[index + 1]
    unless line_number.nil?
      line = @program_lines[line_number]
      statements = line.statements
      statement = statements[0]
      index = statement.start_index
      next_line_index = LineNumberIndex.new(line_number, 0, index)
      return next_line_index
    end

    # nothing left to execute
    nil
  end
end
