require_relative 'game'
require_relative 'view'

class Controller
  attr_accessor :game, :view

  def initialize
    @game = Game.new
    @view = View.new
    @view.clear_screen!
  end

  def symbol_preference
    view.get_symbol
    symbol = gets.chomp.upcase
    game.set_player_preference(symbol)
  end

  def get_player_order
    game.ask_position
  end

  def play_game
    game.start
    announce_outcome
  end

  private
  
  def announce_outcome
    winner = game.winner
    view.print_outcome(winner)
  end
end