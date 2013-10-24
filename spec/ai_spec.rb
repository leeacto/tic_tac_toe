require 'rspec'
require_relative '../ai'
require_relative '../game'

describe Ai do
  describe "Initialize" do
    before(:each) do
      @game = Game.new
      @ai = Ai.new(@game)
    end

    describe "associations" do
      it "should have a view" do
        expect(@ai.view).to be_kind_of View
      end

      it "should have a game" do
        expect(@ai.game).to be_kind_of Game
      end
    end
  end
  
  describe "#go" do
    before(:each) do
      @game = Game.new
      @ai = @game.ai
      @ai.symbol = 'X'
      @ai.user_sym = 'O'
    end

    it "has a an go method" do
      @ai.should respond_to(:go)
    end

    describe "choosing positions" do
      before(:each) do
        @game.turn_count = 1
      end

      context "obvious wins" do
        it "on row" do
          @game.board = [['X','X','3'],
                         ['O','5','6'],
                         ['7','O','9']]
          @ai.go
          expect(@game.board[0][2]).to eq 'X'
        end

        it "on column" do
          @game.board = [['X','2','3'],
                         ['X','5','O'],
                         ['7','O','9']]
          @ai.go
          expect(@game.board[2][0]).to eq 'X'
        end

        it "on diagonal" do
          @game.board = [['X','2','3'],
                         ['4','X','O'],
                         ['7','O','9']]
          @ai.go
          expect(@game.board[2][2]).to eq 'X'
        end
      end

      context "must block" do
        it "on row" do
          @game.board = [['O','O','3'],
                         ['X','5','6'],
                         ['7','X','9']]
          @ai.go
          expect(@game.board[0][2]).to eq 'X'
        end
      end

      context "First Turn" do
        it "chooses the middle" do
          @game.turn_count = 0
          @game.board = [['1','2','3'],
                         ['4','5','6'],
                         ['7','8','9']]
          @ai.go
          expect(@game.board[1][1]).to eq 'X'
        end
      end

      context "Finds Best Move" do
        it "chooses " do
          @game.turn_count = 1
          @game.board = [['X','O','X'],
                         ['4','5','6'],
                         ['7','8','O']]
          @ai.go
          expect(@game.board[2][0]).to eq 'X'
        end
      end
    end
  end
end