require 'debugger'
require_relative 'model'
require_relative 'view'

class Controller
  attr_accessor :game, :view, :turn_count, :symbol_preference, :user_sym, :ai_sym, :user_begin

  def initialize
    @game = Game.new
    @view = View.new
    @turn_count = 0
    @view.clear_screen!
  end

  def symbol_preference
    @view.get_symbol
    test_sym = gets.chomp.upcase
    if valid_symbol?(test_sym)
      @user_sym = test_sym
      @ai_sym = ['X', 'O'].map{|s| s == test_sym ? nil : s }.compact.first
    else
      @view.invalid_sym
      @user_sym = "X"
      @ai_sym = 'O'
    end
  end

  def user_start
    @view.begin_query
    test_start = gets.chomp[0]
    if valid_start?(test_start)
      @user_begin = test_start.to_i
    elsif test_start == nil
      new_begin = "first"
      @user_begin = 1
      sleep(1)
      @view.invalid_begin(new_begin)
    else
      new_start = test_start.ord
      @user_begin = (new_start % 2) + 1
      if @user_begin == 1
        new_begin = "first"
      else
        new_begin = "second"
      end
      @view.invalid_begin(new_begin)
      sleep(1)
    end
  end

  def play_order(user_position)
    if user_position == 1
      ['user_turn','ai_turn']
    else
      ['ai_turn','user_turn']
    end
  end
  
  def play_game
    @play_order = play_order(@user_begin)
    until @game.over?
      self.send(@play_order[@turn_count % 2])
      @turn_count += 1
      @view.print_board(@game.board, user_sym)
      sleep(1)
    end
    winner = outcome(@game.over?)
    @view.print_outcome(winner)
  end

  def user_turn(error=nil)
    @view.print_board(@game.board, @user_sym, error, user_sym)
    user_selection = gets.chomp.to_i
    if valid_position?(user_selection.to_s)
      @game.update_board(user_selection, user_sym)
    else
      user_turn("Invalid Position")
    end
  end

  def valid_symbol?(sym)
    ['X', 'O'].include?(sym)
  end

  def valid_position?(pos)
    @game.open_spots.include?(pos)
  end

  def valid_start?(start)
    ['1', '2'].include?(start)
  end

  def ai_turn
    @view.print_board(@game.board, user_sym,'', ai_sym)
    outcomes = {}
    next_move = next_win(@game.board, ai_sym)
    next_move ||= next_win(@game.board, user_sym)
    next_move ||= @game.last_pos
    unless next_move
      @game.open_spots.each do |pos|
        outcomes[pos] = []
        new_pos_game = create_and_update_board(@game.board, pos.to_i, ai_sym)
        outcomes[pos] << simulate_user(new_pos_game)
        if instant_win?(outcomes[pos])
          next_move = pos
          break 
        end
      end
      next_move ||= best_option(outcomes)
    end
    @game.update_board(next_move.to_i, ai_sym)
  end

  def instant_win?(outcome_hash_values)
    options = outcome_hash_values.flatten.uniq
    options == [ai_sym]
  end

  def next_win(board, sym)
    easy_win = check_row_win(board, sym)
    easy_win ||= check_row_win(board.transpose, sym)
    easy_win ||= check_diag_win(board, sym)
  end

  def check_row_win(board, sym)
    board.each do |row|
      if row.count(sym) == 2 && row.join.gsub('X','').gsub('O','') != ''
        return row.join.gsub('X','').gsub('O','')
      end
    end
    nil
  end

  def check_diag_win(board, sym)
    down_right = [board[0][0],board[1][1],board[2][2]]
    down_left = [board[2][0],board[1][1],board[0][2]]
    diags = [down_left, down_right]
    check_row_win(diags, sym)
  end

  def outcome(symbol_string)
    if symbol_string == 'TIE'
      'TIE'
    elsif symbol_string == @ai_sym
      'AI'
    else
      'HUMAN'
    end
  end
  
  def create_and_update_board(board_array, position_int, symbol)
    new_game = Game.new(board_array.flatten)
    new_game.update_board(position_int, symbol)
    new_game
  end

  def simulate_user(game_obj)
    simulations = []

    if next_win(game_obj.board, user_sym)
      return user_sym
    elsif next_win(game_obj.board, ai_sym)
      #create new board with blocking position
      user_game = create_and_update_board(game_obj.board, next_win(game_obj.board, ai_sym).to_i, user_sym)
      return best_move(user_game)
    else
      #insert each possibility for human selection
      game_obj.open_spots.each do |user_num|
        user_game = create_and_update_board(game_obj.board, user_num.to_i, user_sym)
        if user_game.over?
          return ['TIE']
        else
          simulations << best_move(user_game)
        end
      end
      return simulations
    end
  end

  def best_option(options_hash)
    best_pct = 0.0
    best_pos = ''
    options_hash.each do |k, v|
      return k if v[0].uniq == [ai_sym]
      wins = 0
      ties = 0
      loss = 0
      v[0].flatten.each do |outcome|
        case outcome
        when 'TIE'
          ties +=1
        when ai_sym
          wins += 1
        else
          loss += 1
        end
      end
      
      if (ties + wins).to_f/(ties + wins + loss) > best_pct
        best_pct = (ties + wins).to_f/v[0].flatten.count
        best_pos = k
      end
    end
    best_pos
  end

  def best_move(game_obj)
    endings = []

    #return if there is an obvious winning move
    if next_win(game_obj.board, ai_sym)
      endings << ai_sym
    #create board and block if you must block user
    elsif next_win(game_obj.board, user_sym)
      new_game = create_and_update_board(game_obj.board, next_win(game_obj.board, user_sym).to_i, ai_sym)
      if new_game.over?
        endings << "TIE"
      else
        endings << simulate_user(new_game)
      end
    else
      #make a board for each possible position
      game_obj.open_spots.each do |num|
        new_game = create_and_update_board(game_obj.board, num.to_i, ai_sym)
        #check if game over (all spots taken)
        if new_game.over?
          endings << "TIE"
        else
          endings << simulate_user(new_game)
        end
      end
    end
    endings
  end
end