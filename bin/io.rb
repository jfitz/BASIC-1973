# ConsoleIo class
# Handle tab stops and carriage control
class ConsoleIo
  def initialize(max_width, zone_width, print_rate, implied_semicolon,
                 echo_input)
    @column = 0
    @max_width = max_width
    @zone_width = zone_width
    @print_rate = print_rate
    @implied_semicolon = implied_semicolon
    @last_was_numeric = false
    @echo_input = echo_input
  end

  def ascii_printables(text)
    ascii_text = ''
    text.each_char do |c|
      ascii_text += c if c >= ' ' && c <= '~'
    end
    ascii_text
  end

  def read_line
    input_text = ascii_printables(gets)
    puts(input_text) if @echo_input
    input_text
  end

  def print_item(text)
    text.each_char do |c|
      print_out(c)
      @column += 1
      newline if @column >= @max_width
    end
    @last_was_numeric = false
  end

  def last_was_numeric
    @last_was_numeric = true
  end

  def tab
    space_after_numeric if @last_was_numeric
    print_item(' ') while @column > 0 && @column % @zone_width != 0
    @last_was_numeric = false
  end

  def semicolon
    if @last_was_numeric
      space_after_numeric
      print_item(' ') while @column % 3 != 0
    end
    @last_was_numeric = false
  end

  def implied
    semicolon if @implied_semicolon
    #nothing else otherwise
  end

  def tabto(new_column)
    space_after_numeric if @last_was_numeric
    print_item(' ') while @column < new_column && @column < @max_width
    @last_was_numeric = false
  end

  def columns_to_advance(new_column)
    [new_column - @column, 0].max
  end

  def trace_output(s)
    newline_when_needed
    print_out(s)
    newline
  end

  private

  def space_after_numeric
    count = 3
    while @column > 0 && count > 0
      print_item(' ')
      count -= 1
    end
  end

  public

  def newline
    puts
    delay
    @column = 0
    @last_was_numeric = false
  end

  def newline_when_needed
    newline if @column > 0
  end

  def implied_newline
    @column = 0
  end

  def print_out(text)
    text.each_char do |c|
      print(c)
      delay
    end unless text.nil?
  end

  def delay
    sleep(1.0 / @print_rate) if @print_rate > 0
  end
end
