load './board.rb'
require 'colorize'

class Chess
  COLORS = [:w, :b]
  LETTER_ASSN = {
    'A' => 0,
    'B' => 1,
    'C' => 2,
    'D' => 3,
    'E' => 4,
    'F' => 5,
    'G' => 6,
    'H' => 7,
  }
  NUMBER_ASSN = {
    '1' => 7,
    '2' => 6,
    '3' => 5,
    '4' => 4,
    '5' => 3,
    '6' => 2,
    '7' => 1,
    '8' => 0
  }
  ASSIGNMENTS = LETTER_ASSN.merge(NUMBER_ASSN)

  attr_reader :board

  def initialize(white, black)
    @players = {w: white, b: black}
    @board = Board.new
    board.add_pieces
  end

  def play
    @start_time = Time.now
    @moves = []
    until board.over?
      draw
      @color = COLORS[@moves.count % 2]
      take_move
    end

    recap
  end

  def take_move
    move = nil
    begin
      move = @players[@color].get_move_input(@color)
      board.move(@color, *move)
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

    @moves << move
  end

  def recap
    total_time = Time.now - @start_time
    draw

    finalist = @color == :w ? :b : :w
    if board.checkmate?(finalist)
      win_message = "#{@players[@color].name} won in #{total_time} seconds!"
      puts @color == :w ? win_message.red : win_message.blue
    else
      stale_message =
        "After #{total_time} seconds, #{@players[@color].name} and " +
        "#{@players[finalist].name} are locked in heated battle " +
        "for all eternity...".red_on_black
      puts stale_message
    end
  end

  def draw
    render = ""

    board.grid.each_with_index do |row, i|
      row_ref = NUMBER_ASSN.find { |ref, index| index == i }.first
      render += "     #{row_ref} | "

      row.each_with_index do |piece, j|
        square = piece.class::SYMBOL ||= ' '
        if piece
          square = piece.color == :w ? square.light_red : square.light_blue
        end
        render += (i + j).even? ? " #{square} ".on_white : " #{square} "
      end
      render += "\n"
    end

    render += " " * 8 + "_" * 27 + "\n"
    render += " " * 9
    ('A'..'H').each { |letter| render += " #{letter} " }

    system('clear')
    puts "\n" * 8
    puts render
  end

end

class HumanPlayer
  attr_reader :name

  def initialize(name = 'player')
    @name = name
  end

  def get_move_input(color)
    message = "#{name}, enter your move (eg. 'A1 A3')"
    error_message = "Incorrect format, try again (eg. 'A3 A1')"
    message = color == :w ? message.red : message.blue
    move_selection = prompt(message, error_message) do |input|
      input.upcase =~ /^[A-H][1-8]\s[A-H][1-8]$/
    end.upcase

    parse_move_input(move_selection)
  end

  def parse_move_input(input)
    input.split.map do |pos_str|
      pos_str.reverse.chars.map { |char| Chess::ASSIGNMENTS[char] }
    end
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
  player1 = HumanPlayer.new("Red")
  player2 = HumanPlayer.new("Blue")
  Chess.new(player1, player2).play
end
