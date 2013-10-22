require 'rspec'
require_relative 'controller'

describe Game do
  describe 'Existence' do
    it "has a board" do
      expect(Game.new).to be_true
    end
  end

  describe 'Initialize' do
    before(:each) do
      @game = Game.new
    end

    describe "Board" do
      it "has a board array" do
        expect(@game.board).to be_kind_of(Array)
      end

      it "has 3 slots" do
        @game.board.length.should eq 3
      end

      it "each slot has 3 elements" do
        @game.board[0].length.should eq 3
      end
    end
  end

  describe '#update_board' do
    before(:each) do
      @game = Game.new
    end

    context "with correct inputs" do
      it "replaces the number with the correct symbol" do
        @game.update_board(5, 'X')
        @game.board[1][1].should eq 'X'
      end
    end
  end

  describe '#open_spots' do
    it "returns an array of available positions" do
      @game = Game.new
      @game.board =  [['O','O','O'],
                      ['X','5','6'],
                      ['7','X','9']]
      expect(@game.open_spots).to eq ['5', '6', '7', '9']
    end
  end

  describe '#over?' do
    before(:each) do
      @game = Game.new
    end

    describe "wins" do
      it "finds row wins" do
        @game.board =  [['O','O','O'],
                       ['X','5','6'],
                       ['7','X','9']]
        expect(@game.over?).to eq 'O'
      end

      it "finds column wins" do
        @game.board =  [['X','O','O'],
                       ['X','5','6'],
                       ['X','8','9']]
        expect(@game.over?).to eq 'X'
      end

      it "finds diagonal wins" do
        @game.board =  [['X','O','O'],
                        ['4','X','6'],
                        ['7','8','X']]
        expect(@game.over?).to eq 'X'
      end
    end

    describe "tie" do
      it "claims a tie when board is filled" do
        @game.board =  [['X','O','O'],
                       ['O','X','X'],
                       ['X','X','O']]
        expect(@game.over?).to eq 'TIE'
      end
    end

    describe "not over" do
      it "returns nil when game isn't finished" do
        @game.board =  [['X','O','O'],
                       ['O','X','X'],
                       ['X','X','9']]
        expect(@game.over?).to eq nil
      end
    end
  end

  describe '#row_finished' do
    before(:each) do
      @game = Game.new
    end
    
    it "returns the symbol of a finished row" do
      @game.board =  [['X','X','X'],
                      ['4','O','O'],
                      ['O','8','9']]
      expect(@game.row_finished(@game.board)).to eq 'X'
    end

    it "returns nil when no rows are finished" do
      @game.board =  [['X','2','X'],
                      ['4','O','O'],
                      ['O','8','9']]
      expect(@game.row_finished(@game.board)).to eq nil
    end
  end

  describe '#diag_finished' do
    before(:each) do
      @game = Game.new
    end
    
    it "returns the symbol of a finished row" do
      @game.board =  [['X','O','O'],
                      ['4','X','O'],
                      ['O','8','X']]
      expect(@game.diag_finished(@game.board)).to eq 'X'
    end

    it "returns nil when no diagonals are finished" do
      @game.board =  [['X','2','X'],
                      ['4','O','O'],
                      ['O','8','9']]
      expect(@game.diag_finished(@game.board)).to eq nil
    end
  end

  describe '#tied' do
    before(:each) do
      @game = Game.new
    end
    
    it "returns true for finished games" do
      @game.board =  [['X','O','O'],
                      ['X','X','O'],
                      ['O','O','X']]
      expect(@game.tied).to eq 'TIE'
    end

    it "returns nil for unfinished games" do
      @game.board =  [['X','2','X'],
                      ['4','O','O'],
                      ['O','8','9']]
      expect(@game.tied).to eq nil
    end
  end

  describe '#last_pos' do
    before(:each) do
      @game = Game.new
    end
    
    it "returns the last position when 8 of 9 are filled" do
      @game.board =  [['X','O','X'],
                      ['X','O','O'],
                      ['O','X','9']]
      expect(@game.last_pos).to eq '9'
    end

    it "returns nil if there are multiple options" do
      @game.board =  [['X','O','X'],
                      ['X','O','O'],
                      ['7','8','9']]
      expect(@game.last_pos).to eq nil
    end
  end
end