class SteppingPiece < Piece
  def moves!
    moves = []

    self.deltas.each do |delta|
      new_pos = new_pos(delta)
      moves << new_pos if valid_move?(new_pos)
    end

    moves
  end
end

class Knight < SteppingPiece
  ICON = ?♞

  DELTAS = [
    [1, 2], [1, -2], [2, 1], [2, -1],
    [-1, 2], [-1, -2], [-2, 1], [-2, -1]
  ]

  def deltas
    DELTAS
  end

end

class King < SteppingPiece
  ICON = ?♚
  DELTAS = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1], [0, 1],
    [1, -1], [1, 0], [1, 1]
  ]

  attr_reader :rooks

  def initialize(pos, board, color)
    super
    if color == :w
      @rooks = { [7, 0] => nil, [7, 7] => nil }
    else
      @rooks = { [0, 0] => nil, [0, 7] => nil }
    end
  end

  def deltas
    DELTAS
  end

  def moves!
    super
  end

  def moves
    super + castling_moves
  end

  def castling_moves
    return [] if board.in_check?(color) || board.piece_has_moved?(pos)

    castling_moves = []
    rooks.each do |start_pos, rook|
      next unless board[start_pos] == rook
      next if board.piece_has_moved?(start_pos)
      next if pieces_between?(rook)

      if start_pos[1] < self.pos[1]
        castling_moves << [self.pos[0], 2]
      else
        castling_moves << [self.pos[0], 6]
      end
    end

    castling_moves
  end

  def pieces_between?(rook)
    col = self.pos[1]
    r_col = rook.pos[1]
    piece_range = r_col < col ? ((r_col + 1)...col) : ((col + 1)...r_col)

    piece_range.any? do |col|
      pos = [self.pos[0], col]
      board[pos]
    end
  end

end
