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
