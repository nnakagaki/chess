class Board


  def self.make_board
    Array.new(8) { Array.new(8) }
  end

  def initialize
    @grid = Board.make_board
  end

end

class Piece
  attr_reader :pos

  def initialize(pos, board, color)
    @pos, @board = pos, board
  end

  def take_move

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