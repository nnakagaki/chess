class Piece
  attr_accessor :pos
  attr_reader :color

  def initialize(pos, board, color)
    @pos, @board, @color = pos, board, color
  end

  def inspect
    {
      class: self.class,
      pos: pos,
      color: color
    }.inspect
  end

  def move_into_check?(pos)
    test_board = board.dup
    test_board.move!(self.pos, pos)
    test_board.in_check?(color)
  end

  def other_color
    color == :w ? :b : :w
  end

  def dup(new_board = board)
    self.class.new(pos.dup, new_board, color)
  end

  def non_check_moves
    self.moves.reject { |move| move_into_check?(move) }
  end

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
  SYMBOL = "♟"
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
      new_pos = self.new_pos(delta)
      moves << new_pos if self.valid_move?(move_type, new_pos)
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
      return false unless self.valid_move?(:standard, standard_pos)
    else
      return false unless board[pos] && board[pos].color != color
    end

    true
  end

  def deltas
    color == :w ? WHITE_DELTAS : BLACK_DELTAS
  end

  def pawn_row
    color == :w ? 6 : 1
  end

end

class SlidingPiece < Piece
  DIAGONALS = [ [1, 1], [-1, -1], [1, -1], [-1, 1] ]
  ORTHOGONALS = [ [1, 0], [-1, 0], [0, -1], [0, 1] ]

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
  SYMBOL = "♝"

  def directions
    DIAGONALS
  end
end

class Rook < SlidingPiece
  SYMBOL = "♜"

  def directions
    ORTHOGONALS
  end
end

class Queen < SlidingPiece
  SYMBOL = "♛"

  def directions
    DIAGONALS + ORTHOGONALS
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
  SYMBOL = "♞"

  DELTAS = [
    [1, 2], [1, -2], [2, 1], [2, -1],
    [-1, 2], [-1, -2], [-2, 1], [-2, -1]
  ]

  def deltas
    DELTAS
  end

end

class King < SteppingPiece
  SYMBOL = "♚"
  DELTAS = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1], [0, 1],
    [1, -1], [1, 0], [1, 1]
  ]

  def deltas
    DELTAS
  end

end
