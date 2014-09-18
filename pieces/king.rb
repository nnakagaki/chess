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
      next unless rook_can_castle?(start_pos, rook)

      if start_pos[1] < self.pos[1]
        castling_moves << [self.pos[0], 2]
      else
        castling_moves << [self.pos[0], 6]
      end
    end

    castling_moves
  end

  def rook_can_castle?(start_pos, rook)
    return false unless board[start_pos] == rook
    return false if board.piece_has_moved?(start_pos)
    return false if pieces_between?(rook)
    true
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
