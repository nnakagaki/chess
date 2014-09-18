class Bishop < SlidingPiece
  ICON = ?♝

  def directions
    DIAGONALS
  end
end
