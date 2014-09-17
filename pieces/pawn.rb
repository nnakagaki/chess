class Pawn < Piece
  ICON = ?♟
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
      self.valid_move?(move_type, new_pos)
      moves << new_pos if self.valid_move?(move_type, new_pos)
    end

    moves
  end

  def en_passant_eligible?
    return false unless self == board.last_mover
    start_pos, end_pos = board.moves.last
    (start_pos[0] - end_pos[0]).abs == 2
  end

  def can_take_en_passsant?(move_type)
    diff = move_type == :taking_left ? -1 : 1
    new_pos = [pos[0], pos[1] + diff]
    piece = board[new_pos]
    return false unless piece.is_a?(Pawn)
    piece.en_passant_eligible?
  end

  def valid_move?(move_type, pos)
    return false unless pos.all? { |coord| coord.between?(0, 7) }

    case move_type
    when :standard
      standard_move_valid?(pos)
    when :opening
      opening_move_valid?(pos)
    else
      taking_move_valid?(pos, move_type)
    end
  end

  def standard_move_valid?(pos)
    return false if board[pos]
    true
  end

  def opening_move_valid?(pos)
    return false if board[pos]
    return false unless at_start_row?
    standard_pos = new_pos(deltas[:standard])
    return false unless self.standard_move_valid?(standard_pos)
    true
  end

  def taking_move_valid?(pos, move_type)
    if board[pos]
      return board[pos].color != color
    else
      return can_take_en_passsant?(move_type)
    end
  end

  def deltas
    color == :w ? WHITE_DELTAS : BLACK_DELTAS
  end

  def at_start_row?
     self.pos[0] == (color == :w ? 6 : 1)
  end

  def at_back_row?
    self.pos[0] == (color == :w ? 0 : 7)
  end
end