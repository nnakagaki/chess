class Piece
  attr_reader :color

  def initialize(board, color)
    @board, @color = board, color
  end

  def take_move

  end

  def inspect
    {
      class: self.class,
      color: color
    }.inspect
  end

  protected
  def pos

  end

  private
  attr_reader :board

  def valid_move?(pos)
    return false unless pos.all? { |coord| coord.between?(0, 7) }

    unless board[pos].nil?
      return false if board[pos].color == self.color
    end

    true
  end

  def new_pos(dir, mag = 1)
    i, j = pos
    delta_i, delta_j = dir[0] * mag, dir[1] * mag
    [i + delta_i, j + delta_j]
  end
end

class Pawn < Piece
  BLACK_DELTAS = {
    standard: [1, 0],
    opening: [2, 0],
    taking_left: [1, -1],
    taking_right: [1, 1]
  }
  WHITE_DELTAS = {
    standard: [-1, 0],
    opening: [-2, 0],
    taking_left: [-1, -1],
    taking_right: [-1, 1]
  }

  def moves
    moves = []

    deltas.each do |move_type, delta|
      new_pos = new_pos(delta)
      moves << new_pos if valid_move?(move_type, new_pos)
    end

    moves
  end

  def valid_move?(move_type, pos)
    case move_type
    when :standard
      return false if board[pos]
    when :opening
      return false if board[pos]
      return false if self.pos[0] != pawn_row

      standard_pos = new_pos(deltas[:standard])
      return false if valid_move?(:standard, standard_pos)
    else
      return false unless board[pos] && board[pos].color != self.color
    end

    true
  end

  def deltas
    color == :white ? WHITE_DELTAS : BLACK_DELTAS
  end

  def pawn_row
    color == :white ? 6 : 1
  end

end

class SlidingPiece < Piece
  def moves
    moves = []

    self.directions.each do |dir|
      8.times do |mag|
        next if mag.zero?
        new_pos = new_pos(dir, mag)

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

    self.deltas.each do |delta|
      new_pos = new_pos(delta)
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
