class Queen < SlidingPiece
  ICON = ?♛

  def directions
    DIAGONALS + ORTHOGONALS
  end
end
