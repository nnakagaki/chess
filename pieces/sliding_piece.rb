class SlidingPiece < Piece
  DIAGONALS = [ [1, 1], [-1, -1], [1, -1], [-1, 1] ]
  ORTHOGONALS = [ [1, 0], [-1, 0], [0, -1], [0, 1] ]

  def moves!
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
  ICON = ?♝

  def directions
    DIAGONALS
  end
end

class Rook < SlidingPiece
  ICON = ?♜

  def directions
    ORTHOGONALS
  end
end

class Queen < SlidingPiece
  ICON = ?♛

  def directions
    DIAGONALS + ORTHOGONALS
  end
end