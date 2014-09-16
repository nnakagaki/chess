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

    blocked = false
    deltas.each do |move, delta|
      new_pos = new_pos(delta)
      # puts "#{pos} with #{delta} gives #{new_pos}"

      case move
      when :standard
        next blocked = true if board[new_pos]
      when :opening
        next if blocked || board[new_pos] || pos[0] != pawn_row
      else
        next unless board[new_pos] && board[new_pos].color != self.color
      end

      moves << new_pos
    end
    moves
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
