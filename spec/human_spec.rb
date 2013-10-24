require 'rspec'
require_relative '../human'
require_relative '../game'

describe Human do
 before(:each) do
  @game = Game.new
  @human = @game.human
  Object.any_instance.stub(:valid_symbol?).and_return true
  @game.set_player_preference('O')
 end

 it "has a game associated" do
  expect(@human.game).to be_kind_of Game
 end

 it "has a View" do
  expect(@human.view).to be_kind_of View
 end

 it "has the correct symbol assigned" do
  expect(@human.symbol).to eq 'O'
 end

 describe "#go" do
  context "with valid input" do
    it "updates the board" do
      @human.stub(:gets => "1\n")
      @human.go
      expect(@human.game.board[0][0]).to eq 'O'
    end
  end

  context "with invalid input" do
    it "updates the board" do
      @human.stub(:gets).and_return("10\n", "2\n")
      @human.go
      expect(@human.game.board[0][1]).to eq 'O'
    end
  end
 end
end