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


  attr_reader :board

  def valid_move?(pos)
    return false unless pos.all? { |coord| coord.between?(0, 7) }

    unless board[pos].nil?
      return false if board[pos].color == self.color
    end

    true
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

        if valid_move?(new_pos)
          moves << new_pos
          break if board[new_pos]
        else
          break
        end
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
      moves << new_pos if valid_move?(new_pos)
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