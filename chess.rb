require 'colorize'
require 'yaml'
load './board.rb'
load './human_player.rb'

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

if __FILE__ == $PROGRAM_NAME
  system('clear')
  Chess.new
end
