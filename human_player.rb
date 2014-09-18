class HumanPlayer
  ASSIGNMENTS = {
    ?a => 0,
    ?b => 1,
    ?c => 2,
    ?d => 3,
    ?e => 4,
    ?f => 5,
    ?g => 6,
    ?h => 7,
    ?1 => 7,
    ?2 => 6,
    ?3 => 5,
    ?4 => 4,
    ?5 => 3,
    ?6 => 2,
    ?7 => 1,
    ?8 => 0
  }

  attr_reader :name

  def get_main_menu_input
    message = ""
    error_message = "No such command, try again (n or l)"
    move_selection = prompt(message, error_message) do |input|
      input.downcase =~ /^[nl]$/
    end.downcase

    move_selection == ?n ? :new_game : :load_game
  end


  def get_name(color)
    color_text = color == :w ? "White (Red)" : "Black (Blue)"
    message = "What is your name, #{color_text} Player?"
    @name = prompt(message)
  end

  def get_move_input(color)
    message = "\n#{name}, enter your move (eg. 'A1 A3')"
    error_message = "Incorrect format, try again (eg. 'A3 A1')"
    message = color == :w ? message.red : message.blue
    move_selection = prompt(message, error_message) do |input|
      input.downcase =~ /(^[a-h][1-8]\s[a-h][1-8]$)|(^s$)/
    end.downcase

    move_selection == ?s ? :saving : parse_move_input(move_selection)
  end

  def parse_move_input(input)
    input.split.map do |pos_str|
      pos_str.reverse.chars.map { |char| ASSIGNMENTS[char] }
    end
  end

  def get_pawn_choice(color)
    message =
      "Which piece would you like to upgrade your pawn to? (q, r, b, k)"
    error_message =
      "Enter a letter (q - queen, r - rook, b - bishop, k - knight)"
    choice = prompt(message, error_message) do |input|
      input.downcase =~ /^[qrbk]$/
    end.downcase

    choices = { ?q => Queen, ?r => Rook, ?b => Bishop, ?k => Knight }

    choices[choice]
  end

  private
  def prompt(message, error_message = nil, &prc)
    error_message ||= message
    prc ||= Proc.new { true }

    print "#{message} "
    begin
      input = gets.chomp
      raise ArgumentError("Block failed!") unless prc.call(input)
    rescue
      print "#{error_message}: "
      retry
    end

    input
  end
end
