load './board.rb'
require 'colorize'
require 'yaml'

class Chess
  COLORS = [:w, :b]

  attr_reader :board, :players

  def initialize
    main_menu
    @players = {}
  end

  def main_menu
    puts "\n" * 5
    indent = 10
    puts " " * indent + "     WELCOME."
    puts " " * indent + "        TO"
    puts " " * indent + "THE WORLD OF CHESS!"
    puts "\n" * 2

    puts " " * (indent+2) + "n => New Game"
    puts " " * (indent+2) + "l => Load"
    puts "\n" * 2
    print " " * (indent+5)

    temp_player = HumanPlayer.new
    input = temp_player.get_main_menu_input

    play if input == ?n
    load_file if input == ?l
  end

  def get_players
    white = HumanPlayer.new(:w)
    black = HumanPlayer.new(:b)
    @players = {w: white, b: black}
  end

  def play
    @board = Board.new
    board.add_pieces
    board.draw

    get_players

    @start_time = Time.now
    @color = :w

    run

  end

  def run
    until board.over?(@color)
      board.draw
      take_move
      if board.pawn_to_back_row?
        board.draw
        choice = players[@color].get_pawn_choice(@color)
        board.upgrade_pawn(choice)
      end

      @color = (@color == :w ? :b : :w)
    end

    recap
  end

  def take_move
    move = nil
    puts move
    begin
      move = @players[@color].get_move_input(@color)
      if move == 'S'
        save_file
        take_move
      else
        board.move(@color, *move)
      end
    rescue NoPieceError
      puts "There's no piece there!"
      retry
    rescue InvalidMoveError
      puts "Can't move there... try again?"
      retry
    rescue PlayerError
      puts "That's not your piece!"
      retry
    else
    end
  end

  def recap
    total_time = Time.now - @start_time
    board.draw

    finalist = @color == :w ? :b : :w
    if board.checkmate?(@color)
      win_message = "#{@players[finalist].name} won in #{total_time} seconds!"
      puts finalist == :w ? win_message.red : win_message.blue
    else
      stale_message =
        "After #{total_time} seconds, #{@players[@color].name} and " +
        "#{@players[finalist].name} are locked in heated battle " +
        "for all eternity..."
      puts stale_message.red
    end
  end

  def save_file
    puts "What would you like to name your save file?"
    filename = gets.chomp + ".yml"
    File.write(filename, YAML.dump(self))
  end

  def load_file
    puts "What is the name of your save file?"
    filename = gets.chomp
    begin
      YAML.load_file(filename).run
    rescue
      puts "That file doesn't exist; try again!"
    end
  end

end

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

if __FILE__ == $PROGRAM_NAME
  system('clear')
  Chess.new
end
