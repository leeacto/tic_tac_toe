require_relative 'human'
require_relative 'ai'

class Game
  attr_accessor :board, :view, :ai, :human, :turn_count, :play_order, :user_sym

  def initialize(board=nil)
    if board
      @board = [[board[0],board[1],board[2]],
                [board[3],board[4],board[5]],
                [board[6],board[7],board[8]]]
    else
      @board = [['1','2','3'],
                ['4','5','6'],
                ['7','8','9']]
    end
    @view = View.new
    @turn_count = 0
    @human = Human.new(self)
    @ai = Ai.new(self)
  end

  def update_board(position_int, symbol)
    indexed = position_int - 1
    row = indexed / 3
    column = indexed % 3
    self.board[row][column] = symbol
  end

  def open_spots
    board.flatten.join.gsub('X','').gsub('O','').split('')
  end

  def over?
    winner = row_finished(@board)
    winner ||= row_finished(@board.transpose)
    winner ||= diag_finished
    winner ||= tied
  end

  def last_pos
    return self.open_spots.first if self.open_spots.count == 1
  end

  def set_player_preference(sym)
    if valid_symbol?(sym)
      @human.symbol = sym
      @ai.user_sym = sym
      @ai.symbol = ['X', 'O'].map{|s| s == sym ? nil : s }.compact.first
    else
      view.invalid_sym
      @human.symbol = 'X'
      @ai.symbol = 'O'
      @ai.user_sym = 'X'
    end
  end

  def ask_position
    view.begin_query
    test_start = gets.chomp[0]
    if valid_start?(test_start)
      user_begin = test_start.to_i
    elsif test_start == nil
      new_begin = 'first'
      user_begin = 1
      view.invalid_begin(new_begin)
      sleep(1)
    else
      new_start = test_start.ord
      user_begin = (new_start % 2) + 1
      if user_begin == 1
        new_begin = 'first'
      else
        new_begin = 'second'
      end
      sleep(1)
      view.invalid_begin(new_begin)
    end
    set_order(user_begin)
  end

  def start
    until over?
      @play_order[@turn_count % 2].go
      @turn_count += 1
      view.print_board(board, user_sym)
      sleep(1)
    end
  end

  def winner
    case over?
    when @ai.symbol
      @ai.to_s
    when @human.symbol
      @human.to_s
    when nil
      nil
    else
      'TIE'
    end
  end

  private

  def valid_symbol?(sym)
    ['X', 'O'].include?(sym)
  end

  def valid_start?(start)
    ['1', '2'].include?(start)
  end
  
  def row_finished(rows)
    rows.each do |row|
      single_x_or_o = row.uniq.join
      if single_x_or_o == 'X' || single_x_or_o == 'O'
        return single_x_or_o
      end
    end
    nil
  end

  def set_order(user_pos)
    if user_pos == 1
      @play_order = [@human, @ai]
    else
      @play_order = [@ai, @human]
    end
  end

  def diag_finished
    down_right = [board[0][0],board[1][1],board[2][2]]
    down_left = [board[2][0],board[1][1],board[0][2]]
    diags_as_rows = [down_left, down_right]
    row_finished(diags_as_rows)
  end

  def tied
    return 'TIE' if self.open_spots == []
  end
end