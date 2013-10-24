require_relative 'game'
require_relative 'player'

class Human < Player
  attr_reader :view, :game
  attr_accessor :symbol

  def initialize(game)
    super
  end

  def go(error=nil)
    @view.print_board(@game.board, symbol, error, symbol)
    user_selection = gets.chomp.to_i
    if valid_position?(user_selection.to_s)
      @game.update_board(user_selection, symbol)
    else
      go('Invalid Position')
    end
  end

  def to_s
    'HUMAN'
  end
end