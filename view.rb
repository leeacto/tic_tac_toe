class View
  attr_reader :get_symbol

  def get_symbol
    print "Which symbol do you want (X or O)? "
  end

  def invalid_sym
    puts "Invalid Entry. I'm just going to give you X"
  end

  def begin_query
    print "Would you like to go first or second (1 or 2)? "
  end

  def invalid_begin(new_begin)
    puts "Invalid Entry. You will go #{new_begin}."
  end

  def invalid_spot
    puts "Position is Invalid. Try again."
  end

  def clear_screen!
    print "\e[2J"
    print "\e[H"
  end

  def print_outcome(winner_string)
    if winner_string == 'TIE'
      puts 'THE GAME WAS A TIE!'
    else
      puts "#{winner_string} WINS!"
    end
  end

  def print_board(board, user_sym, error=nil, turn_sym=nil)
    self.clear_screen!
    puts error if error
    puts "#{turn_sym}'s Turn" if turn_sym
    puts "You are #{user_sym}"
    puts
    puts <<-EOF
      #{board[0][0]} | #{board[0][1]} | #{board[0][2]}
    ----+---+---
      #{board[1][0]} | #{board[1][1]} | #{board[1][2]}
    ----+---+---
      #{board[2][0]} | #{board[2][1]} | #{board[2][2]}

    Enter your choice: 
    EOF
  end

  private
end
