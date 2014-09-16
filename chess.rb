# require_relative 'pieces.rb'
load './pieces.rb'

class CoordinateError < RuntimeError
end

class Board
  attr_reader :grid

  PIECE_ORDER = [
    Rook, Knight, Bishop, Queen,
    King, Bishop, Knight, Rook
  ]

  def self.make_board
    Array.new(8) { Array.new(8) }
  end

  def initialize
    @grid = Board.make_board
  end

  def move(start_pos, end_pos)
    piece = self[start_pos]
    raise CoordinateError("No piece there!") unless piece
    unless piece.non_check_moves.include?(end_pos)
      raise CoordinateError("Can't move there!")
    end

    move!(start_pos, end_pos)
  end

  def move!(start_pos, end_pos)
    piece = self[start_pos]
    self[start_pos] = nil
    self[end_pos] = piece
    piece.pos = end_pos
  end

  def in_check?(color)
    king = king_for_color(color)

    pieces_for_color(king.other_color).any? do |piece|
      piece.moves.include?(king.pos)
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
    pieces.each do |piece|
      new_piece = piece.dup(new_board)
      new_board[new_piece.pos] = new_piece
    end

    new_board
  end

  def pieces
    grid.flatten.compact
  end

  private
  def add_pieces
    grid.each_with_index do |row, index|
      color = [0, 1].include?(index) ? :black : :white

      if [0, 7].include?(index)
        set_back_row(row, index, color)
      elsif [1, 6].include?(index)
        set_pawn_row(row, index, color)
      end
    end
  end

  def set_back_row(row, row_index, color)
    8.times do |index|
      row[index] = PIECE_ORDER[index].new(self, color)
    end
  end

  def set_pawn_row(row, row_index, color)
    8.times do |index|
      row[index] = Pawn.new(self, color)
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

