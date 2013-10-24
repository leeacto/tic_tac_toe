require_relative 'view'

class Player
  attr_reader :game

  def initialize(game)
    @view = View.new
    @game = game
  end

  private

  def valid_position?(pos)
    @game.open_spots.include?(pos)
  end
end