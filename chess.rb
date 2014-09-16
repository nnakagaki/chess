load './board.rb'

class Chess
  COLORS = [:w, :b]

  def initialize(white, black)
    @players = {w: white, b: black}
    @board = Board.new
    @board.add_pieces
  end

  def play
    moves = []
    until board.over?
      color = COLORS[moves.count % 2]

      begin
        start_pos, end_pos = @players[color].get_move_input
        @board.move(start_pos, end_pos)
      rescue CoordinateError("Can't move there... try again?")
        retry
      end

    end
  end

  def draw

  end

end

class HumanPlayer
  ASSIGNMENTS = {
    'a' => 0,
    'b' => 1,
    'c' => 2,
    'd' => 3,
    'e' => 4,
    'f' => 5,
    'g' => 6,
    'h' => 7,
    '1' => 7,
    '2' => 6,
    '3' => 5,
    '4' => 4,
    '5' => 3,
    '6' => 2,
    '7' => 1,
    '8' => 0
  }

  attr_accessor :color

  def initialize(name = 'player')
    @name = name
  end

  def get_move_input
    message = "Enter your move (eg. 'a1 a3')"
    error_message = "Incorrect format, try again (eg. 'a3 a1')"
    prompt(message, error_message) do |input|
      input.downcase =~ /^[a-h][1-8]\s[a-h][1-8]$/
    end

    parse_move_input(input)
  end

  def parse_move_input(input)
    input.split.map do |pos_str|
      pos_str.chars.map { |char| ASSIGNMENTS[char] }
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
  end
end

if __FILE__ == $PROGRAM_NAME
  player1 = HumanPlayer.new
  player2 = HumanPlayer.new
  Chess.new(player1, player2).play
end
