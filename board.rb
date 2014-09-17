load './pieces.rb'

class NoPieceError < RuntimeError
end

class InvalidMoveError < RuntimeError
end

class PlayerError < RuntimeError
end

class Board
  attr_reader :grid
  attr_reader :moves

  PIECE_ORDER = [
    Rook, Knight, Bishop, Queen,
    King, Bishop, Knight, Rook
  ]

  def self.make_board
    Array.new(8) { Array.new(8) }
  end

  def initialize
    @grid, @moves = Board.make_board, []
  end

  def move(color, start_pos, end_pos)
    piece = self[start_pos]
    raise NoPieceError unless piece
    raise PlayerError if piece.color != color
    unless piece.non_check_moves.include?(end_pos)
      raise InvalidMoveError
    end

    move!(start_pos, end_pos)
  end

  def move!(start_pos, end_pos)
    en_passant_take if en_passant?(start_pos, end_pos)

    piece = self[start_pos]
    self[start_pos] = nil
    self[end_pos] = piece
    piece.pos = end_pos

    moves << [start_pos, end_pos]
  end


  def en_passant?(start_pos, end_pos)
    current_piece = self[start_pos]
    return false unless [current_piece, last_mover].all? do |piece|
      piece.is_a?(Pawn)
    end
    puts "what!?"
    return false unless last_mover.en_passant_eligible?

    start_pos[0] == last_mover.pos[0] && end_pos[1] == last_mover.pos[1]
  end

  def en_passant_take
    self[moves.last.last] = nil
  end

  def in_check?(color)
    king = king_for_color(color)

    pieces_for_color(king.other_color).any? do |piece|
      piece.moves.include?(king.pos)
    end
  end

  def over?(color)
    return false if moves.empty?
    checkmate?(color) || stalemate?(color)
  end

  def checkmate?(color)
    return false unless in_check?(color)

    pieces_for_color(color).all? do |piece|
      piece.non_check_moves.empty?
    end
  end

  def stalemate?(color)
    return false if in_check?(color)

    pieces_for_color(color).all? do |piece|
      piece.non_check_moves.empty?
    end
  end

  def [](pos)
    grid[ pos[0] ][ pos[1] ]
  end

  def []=(pos, value)
    grid[ pos[0] ][ pos[1] ] = value
  end

  def dup
    new_board = Board.new
    new_board.moves = self.moves.map(&:dup)
    pieces.each do |piece|
      new_piece = piece.dup(new_board)
      new_board[new_piece.pos] = new_piece
    end

    new_board
  end

  def pieces
    grid.flatten.compact
  end

  def last_mover
    return nil if moves.empty?
    self[moves.last.last]
  end

  def add_pieces
    set_back_rows
    set_pawn_rows
  end

  def draw
    render = ""

    grid.each_with_index do |row, i|
      render += "     #{8 - i} | "

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

  protected
  attr_writer :moves

  private
  def set_back_rows
    [:w, :b].each do |color|
      row = color == :w ? 7 : 0
      8.times do |col|
        pos = [row, col]
        self[pos] = PIECE_ORDER[col].new(pos, self, color)
      end
    end
  end

  def set_pawn_rows
    [:w, :b].each do |color|
      row = color == :w ? 6 : 1
      8.times do |col|
        pos = [row, col]
        self[pos] = Pawn.new(pos, self, color)
      end
    end
  end

  def pieces_for_color(color)
    pieces.select { |piece| piece.color == color }
  end

  def king_for_color(color)
    pieces.select do |piece|
      piece.color == color && piece.is_a?(King)
    end.first
  end

end
