class Board

end

class Piece
  attr_reader :pos

  def initialize(pos, board)
    @pos, @board = pos, board
  end

  def move

  end
end

class SlidingPiece < Piece

end

class Bishop < SlidingPiece

end

class Rook < SlidingPiece

end

class Queen < SlidingPiece

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