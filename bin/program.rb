# program container
class Program
  def initialize(console_io, tokenizers)
    @console_io = console_io
    @program_lines = {}
    @statement_factory = StatementFactory.instance
    @statement_factory.tokenizers = tokenizers
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

  def list(linespec, list_tokens)
    linespec = linespec.strip
    if !@program_lines.empty?
      begin
        line_numbers = @program_lines.keys.sort
        line_number_range = LineListSpec.new(linespec, line_numbers)
        line_numbers = line_number_range.line_numbers
        list_lines_errors(line_numbers, list_tokens)
      rescue BASICException => e
        @console_io.print_line(e)
      end
    else
      @console_io.print_line('No program loaded')
    end
  end

  def pretty(linespec)
    linespec = linespec.strip
    if !@program_lines.empty?
      begin
        line_numbers = @program_lines.keys.sort
        line_number_range = LineListSpec.new(linespec, line_numbers)
        line_numbers = line_number_range.line_numbers
        pretty_lines_errors(line_numbers)
      rescue BASICException => e
        @console_io.print_line(e)
      end
    else
      @console_io.print_line('No program loaded')
    end
  end

  def profile(linespec)
    linespec = linespec.strip
    if !@program_lines.empty?
      begin
        line_numbers = @program_lines.keys.sort
        line_number_range = LineListSpec.new(linespec, line_numbers)
        line_numbers = line_number_range.line_numbers
        profile_lines_errors(line_numbers)
      rescue BASICException => e
        @console_io.print_line(e)
      end
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

  def delete(linespec)
    if @program_lines.empty?
      @console_io.print_line('No program loaded')
    else
      delete_lines(linespec.strip)
    end
  end

  def delete_lines(linespec)
    line_numbers = @program_lines.keys.sort
    line_number_range = LineListSpec.new(linespec.strip, line_numbers)
    line_numbers = line_number_range.line_numbers
    case line_number_range.range_type
    when :single
      delete_specific_lines(line_numbers)
    when :range
      list_and_delete_lines(line_numbers)
    when :all
      @console_io.print_line('Type NEW to delete an entire program')
    end
  rescue BASICException => e
    @console_io.print_line(e)
  end

  def renumber
    # generate new line numbers
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
      pretty = line.pretty
      @console_io.print_line(number + pretty)
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