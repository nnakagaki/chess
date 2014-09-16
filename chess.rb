# require_relative 'pieces.rb'
load './pieces.rb'

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
    add_pieces
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
    grid.flatten.select { |piece| piece.color == color }
  end

  def king_for_color(color)
    grid.flatten.select do |piece|
      piece.color == color && piece.is_a?(King)
    end.first
  end

end

