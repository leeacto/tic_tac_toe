require_relative 'player'
require_relative 'human'
require_relative 'game'
require 'debugger'
class Ai < Player
  attr_reader :view
  attr_accessor :symbol, :user_sym

  def initialize(game)
    super
  end

  def go(error=nil)

    view.print_board(@game.board, @user_sym,'', symbol)
    if @game.turn_count == 0
      next_move = '5'
    else
      next_move = next_win(@game.board, symbol)
      next_move ||= next_win(@game.board, @user_sym)
      next_move ||= @game.last_pos
      next_move ||= find_best_move
    end
    game.update_board(next_move.to_i, symbol)
  end

  def to_s
    'AI'
  end

  private

  def find_best_move
    outcomes = {}
    game.open_spots.each do |pos|
      outcomes[pos] = []
      new_pos_game = create_and_update_board(@game.board, pos.to_i, symbol)
      outcomes[pos] << simulate_user(new_pos_game)
      if instant_win?(outcomes[pos])
        next_move = pos
        break 
      end
    end
    next_move ||= best_option(outcomes)
  end

  def create_and_update_board(board_array, position_int, symbol)
    new_game = Game.new(board_array.flatten)
    new_game.update_board(position_int, symbol)
    new_game
  end

  def best_option(options_hash)
    best_score = -10000
    best_pos = ''
    options_hash.each do |k, v|
      return k if v[0].uniq == [symbol]

      outcome_score = score(v[0].flatten)
      if outcome_score > best_score
        best_score = outcome_score
        best_pos = k
      end
    end
    best_pos
  end

  def score(outcome_array)
    score = 0
    outcome_array.each do |outcome|
      case outcome
      when 'TIE'
        score +=1
      when symbol
        score += 1
      else
        score -= 200
      end
    end
    score
  end

  def best_move(game_obj)
    endings = []

    #return if there is an obvious winning move
    if next_win(game_obj.board, symbol)
      endings << symbol
    #create board and block if you must block user
    elsif next_win(game_obj.board, @user_sym)
      new_game = create_and_update_board(game_obj.board, next_win(game_obj.board, @user_sym).to_i, symbol)
      if new_game.over?
        endings << 'TIE'
      else
        endings << simulate_user(new_game)
      end
    else
      #make a board for each possible position
      game_obj.open_spots.each do |num|
        new_game = create_and_update_board(game_obj.board, num.to_i, symbol)
        #check if game over (all spots taken)
        if new_game.over?
          endings << 'TIE'
        else
          endings << simulate_user(new_game)
        end
      end
    end
    endings
  end

  def simulate_user(game_obj)
    simulations = []

    if next_win(game_obj.board, @user_sym)
      return [@user_sym]
    elsif next_win(game_obj.board, symbol)
      #create new board with blocking position
      user_game = create_and_update_board(game_obj.board, next_win(game_obj.board, symbol).to_i, @user_sym)
      return best_move(user_game)
    else
      #insert each possibility for human selection
      game_obj.open_spots.each do |user_num|
        user_game = create_and_update_board(game_obj.board, user_num.to_i, @user_sym)
        if user_game.over?
          return ['TIE']
        else
          simulations << best_move(user_game)
        end
      end
      return simulations
    end
  end

  def instant_win?(outcome_hash_values)
    options = outcome_hash_values.flatten.uniq
    options == [symbol]
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
end