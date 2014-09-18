class BoardChecker
  attr_reader :board, :moves, :past_grids

  def initialize(board)
    @board = board
    @moves, @past_grids = [], []
  end

  def last_mover
    return nil if moves.empty?
    board[moves.last.last]
  end

  def in_check?(color)
    king = board.king_for_color(color)

    board.pieces_for_color(king.other_color).any? do |piece|
      piece.moves!.include?(king.pos)
    end
  end

  def over?(color)
    return false if moves.empty?
    checkmate?(color) || stalemate?(color)
  end

  def checkmate?(color)
    return false unless in_check?(color)

    board.pieces_for_color(color).all? do |piece|
      piece.non_check_moves.empty?
    end
  end

  def stalemate?(color)
    return true if repeated_board_stalemate?
    no_moves_stalemate?(color)
  end

  def repeated_board_stalemate?
    board_freq = Hash.new(0)
    return true if past_grids.any? do |past_grid|
      board_freq[past_grid] += 1
      board_freq[past_grid] > 2
    end
  end

  def no_moves_stalemate?(color)
    return false if moves.count < 6 || in_check?(color)

    board.pieces_for_color(color).all? do |piece|
      piece.non_check_moves.empty?
    end
  end

  def pawn_to_back_row?
    last_mover.is_a?(Pawn) && last_mover.at_back_row?
  end

  def piece_has_moved?(pos)
    moves.any? { |move| move[0] == pos }
  end

  def en_passant?(start_pos, end_pos)
    current_piece = board[start_pos]
    return false unless [current_piece, last_mover].all? do |piece|
      piece.is_a?(Pawn)
    end
    return false unless last_mover.en_passant_eligible?

    start_pos[0] == last_mover.pos[0] && end_pos[1] == last_mover.pos[1]
  end

  def castling?(start_pos, end_pos)
    board[start_pos].class == King && (start_pos[1] - end_pos[1]).abs == 2
  end

  def dup(board = self.board)
    checker = BoardChecker.new(board)
    checker.moves = self.moves.map(&:dup)
    checker.past_grids = self.past_grids.map(&:dup)

    checker
  end

  protected
  attr_writer :moves, :past_grids

end
