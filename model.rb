class Game
  attr_accessor :board, :view

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
  end

  def update_board(position_int, symbol)
    indexed = position_int - 1
    row = indexed / 3
    column = indexed % 3
    self.board[row][column] = symbol
  end

  def open_spots
    @board.flatten.join.gsub('X','').gsub('O','').split('')
  end

  def over?
    winner = row_finished(@board)
    winner ||= row_finished(@board.transpose)
    winner ||= diag_finished(@board)
    winner ||= tied
  end

  def row_finished(board)
    board.each do |row|
      single_x_or_o = row.uniq.join
      if single_x_or_o == 'X' || single_x_or_o == 'O'
        return single_x_or_o
      end
    end
    nil
  end

  def diag_finished(board)
    down_right = [board[0][0],board[1][1],board[2][2]]
    down_left = [board[2][0],board[1][1],board[0][2]]
    diags = [down_left, down_right]
    row_finished(diags)
  end

  def tied
    return 'TIE' if self.open_spots == []
  end

  def last_pos
    return self.open_spots.first if self.open_spots.count == 1
  end
end