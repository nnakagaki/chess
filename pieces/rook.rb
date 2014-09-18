class Rook < SlidingPiece
  ICON = ?♜

  def directions
    ORTHOGONALS
  end
end
