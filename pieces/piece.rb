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

  def moves
    moves!
  end

  def new_pos(dir, mag = 1)
    i, j = pos
    delta_i, delta_j = dir[0] * mag, dir[1] * mag
    [i + delta_i, j + delta_j]
  end
end