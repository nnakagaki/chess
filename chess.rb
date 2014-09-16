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

end

