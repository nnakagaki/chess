load './pieces.rb'
load './board_checker.rb'

class NoPieceError < RuntimeError
end

class InvalidMoveError < RuntimeError
end

class PlayerError < RuntimeError
end

class Board
  PIECE_ORDER = [
    Rook, Knight, Bishop, Queen,
    King, Bishop, Knight, Rook
  ]

  attr_reader :grid, :checker

  def self.make_grid
    Array.new(8) { Array.new(8) }
  end

  def initialize
    @grid = Board.make_grid
    @checker = BoardChecker.new(self)
  end

  def move(color, start_pos, end_pos)
    piece = self[start_pos]
    raise NoPieceError unless piece
    raise PlayerError if piece.color != color
    unless piece.non_check_moves.include?(end_pos)
      raise InvalidMoveError
    end

    move!(start_pos, end_pos)
  end

  # Allows moving without error checks for creating hypothetical boards
  def move!(start_pos, end_pos)
    handle_special_moves(start_pos, end_pos)
    piece = self[start_pos]
    update_piece_position(piece, start_pos, end_pos)

    moves << [start_pos, end_pos]
    checker.past_grids << symbol_grid
  end

  def update_piece_position(piece, start_pos, end_pos)
    self[start_pos] = nil
    self[end_pos] = piece
    piece.pos = end_pos
  end

  def [](pos)
    grid[ pos[0] ][ pos[1] ]
  end

  def []=(pos, value)
    grid[ pos[0] ][ pos[1] ] = value
  end

  def dup
    new_board = Board.new
    new_board.checker = self.checker.dup(new_board)
    pieces.each do |piece|
      new_piece = piece.dup(new_board)
      new_board[new_piece.pos] = new_piece
    end

    new_board
  end

  def add_pieces
    set_back_rows
    set_pawn_rows
    set_king_rooks
  end

  def upgrade_pawn(choice)
    color = last_mover.color
    pos = last_mover.pos
    self[pos] = choice.new(pos, self, color)
  end

  def pieces
    grid.flatten.compact
  end

  def pieces_for_color(color)
    pieces.select { |piece| piece.color == color }
  end

  def king_for_color(color)
    pieces.select do |piece|
      piece.color == color && piece.is_a?(King)
    end.first
  end

  def moves
    checker.moves
  end

  def draw
    render = ""

    grid.each_with_index do |row, i|
      render += "     #{8 - i} ║ "

      row.each_with_index do |piece, j|
        square = piece.class::ICON ||= ' '
        if piece
          square = piece.color == :w ? square.light_red : square.light_blue
        end
        render += (i + j).even? ? " #{square} ".on_white : " #{square} "
      end
      render += " " + "║" + "\n"
    end

    render += " " * 7 + "╚" + "═" * 26 + "╝" + "\n"
    render = " " * 7 + "╔" + "═" * 26 + "╗" + "\n" + render
    render += " " * 9
    ('A'..'H').each { |letter| render += " #{letter} " }

    system('clear')
    puts "\n" * 8
    puts render
  end

  protected
  attr_writer :checker

  private
  def symbol_grid
    grid.flatten.map do |piece|
      next unless piece
      (piece.class::ICON + piece.color.to_s).to_sym
    end
  end

  def set_back_rows
    [:w, :b].each do |color|
      row = color == :w ? 7 : 0
      8.times do |col|
        pos = [row, col]
        self[pos] = PIECE_ORDER[col].new(pos, self, color)
      end
    end
  end

  def set_pawn_rows
    [:w, :b].each do |color|
      row = color == :w ? 6 : 1
      8.times do |col|
        pos = [row, col]
        self[pos] = Pawn.new(pos, self, color)
      end
    end
  end

  def set_king_rooks
    [:w, :b].each do |color|
      king = king_for_color(color)
      king.rooks.each do |start_pos, value|
        king.rooks[start_pos] = self[start_pos]
      end
    end
  end

  def handle_special_moves(start_pos, end_pos)
    if checker.en_passant?(start_pos, end_pos)
      en_passant_take
    elsif checker.castling?(start_pos, end_pos)
      castling_rook_move(start_pos, end_pos)
    end
  end

  def en_passant_take
    self[moves.last.last] = nil
  end

  def castling_rook_move(start_pos, end_pos)
    row = start_pos[0]
    col = end_pos[1] == 2 ? 0 : 7
    from_pos = [row, col]
    rook = self[from_pos]

    to_col = col == 0 ? 3 : 5
    to_pos = [row, to_col]
    update_piece_position(rook, from_col, to_col)
  end

end
