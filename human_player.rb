class HumanPlayer
  ASSIGNMENTS = {
    'A' => 0,
    'B' => 1,
    'C' => 2,
    'D' => 3,
    'E' => 4,
    'F' => 5,
    'G' => 6,
    'H' => 7,
    '1' => 7,
    '2' => 6,
    '3' => 5,
    '4' => 4,
    '5' => 3,
    '6' => 2,
    '7' => 1,
    '8' => 0
  }

  attr_reader :name

  def initialize(color = :temp)
    if color == :temp
      @name = ""
    else
      @name = get_name(color)
    end
  end

  def get_name(color)
    player_color = color == :w ? "White (Red)" : "Black (Blue)"
    puts "\n"
    puts "  What is your name, #{player_color} Player!"
    print "  "
    gets.chomp
  end

  def get_move_input(color)
    message = "\n  #{name}, enter your move (eg. 'A1 A3')"
    error_message = "Incorrect format, try again (eg. 'A3 A1')"
    message = color == :w ? message.red : message.blue
    move_selection = prompt(message, error_message) do |input|
      input.upcase =~ /(^[A-H][1-8]\s[A-H][1-8]$)|(^[S]$)/
    end.upcase

    if move_selection == "S"
      move_selection
    else
      parse_move_input(move_selection)
    end
  end

  def parse_move_input(input)
    input.split.map do |pos_str|
      pos_str.reverse.chars.map { |char| ASSIGNMENTS[char] }
    end
  end

  def get_pawn_choice(color)
    message =
      "Which piece would you like to upgrade your pawn to (q, r, b, k)"
    error_message =
      "Choose a letter (q - queen, r - rook, b - bishop, k - knight)"
    choice = prompt(message, error_message) do |input|
      input.upcase =~ /^[QRBK]$/
    end.upcase

    choices = { ?Q => Queen, ?R => Rook, ?B => Bishop, ?K => Knight }

    choices[choice]
  end

  def get_main_menu_input
    message = ""
    error_message = "No such command, try again (n or l)"
    move_selection = prompt(message, error_message) do |input|
      input.downcase =~ /^[nl]$/
    end.downcase
  end

  def prompt(message, error_message, &prc)
    print "#{message} "
    begin
      input = gets.chomp
      raise ArgumentError("Block failed!") unless prc.call(input)
    rescue
      print "#{error_message}: "
      retry
    end

    input
  end
end
