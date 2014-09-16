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
      pos = [row_index, index]
      row[index] = PIECE_ORDER[index].new(pos, self, color)
    end
  end

  def set_pawn_row(row, row_index, color)
    8.times do |index|
      pos = [row_index, index]
      row[index] = Pawn.new(pos, self, color)
    end
  end

end

class Piece
  attr_reader :pos, :color

  def initialize(pos, board, color)
    @pos, @board, @color = pos, board, color
  end

  def take_move

  end

  def inspect
    {
      class: self.class,
      pos: pos,
      color: color
    }.inspect
  end
end

class SlidingPiece < Piece
  def moves
    moves = []

    i, j = pos
    self.directions.each do |dir|
      8.times do |mag|
        next if mag.zero?
        delta_i, delta_j = dir[0] * mag, dir[1] * mag
        new_pos = [i + delta_i, j + delta_j]
        break unless new_pos.all? { |coord| coord.between?(0, 7) }

        moves << new_pos
      end
    end

    moves
  end
end

class Bishop < SlidingPiece
  DIRECTIONS = [ [1, 1], [-1, -1], [1, -1], [-1, 1] ]

  def directions
    DIRECTIONS
  end
end

class Rook < SlidingPiece
  DIRECTIONS = [ [1, 0], [-1, 0], [0, -1], [0, 1] ]

  def directions
    DIRECTIONS
  end
end

class Queen < SlidingPiece
  DIRECTIONS = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1], [0, 1],
    [1, -1], [1, 0], [1, 1]
  ]

  def directions
    DIRECTIONS
  end
end

class SteppingPiece < Piece
  def moves
    moves = []

    i, j = pos
    self.deltas.each do |delta|
      new_pos = [i + delta[0], j + delta[1]]

      if new_pos.all? { |coord| coord.between?(0, 7) }
        moves << new_pos
      end
    end

    moves
  end
end

class Knight < SteppingPiece
  DELTAS = [
    [1, 2], [1, -2], [2, 1], [2, -1],
    [-1, 2], [-1, -2], [-2, 1], [-2, -1]
  ]

  def deltas
    DELTAS
  end

end

class King < SteppingPiece
  DELTAS = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1], [0, 1],
    [1, -1], [1, 0], [1, 1]
  ]

  def deltas
    DELTAS
  end

end

class Pawn < Piece

end