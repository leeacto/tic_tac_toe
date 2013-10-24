require 'rspec'
require_relative '../game'

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

    describe 'Board' do
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

    describe "View" do
      it "has a View Object" do
        expect(@game.view).to be_kind_of(View)
      end
    end

    describe "turn_count" do
      it "has a turn_count" do
        expect(@game.turn_count).to eq 0
      end
    end

    describe "Human" do
      it "has a Human Object" do
        expect(@game.human).to be_kind_of(Human)
      end
    end

    describe "AI" do
      it "has a AI Object" do
        expect(@game.ai).to be_kind_of(Ai)
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
    
    it "#over? returns the symbol of a finished row" do
      @game.board =  [['X','X','X'],
                      ['4','O','O'],
                      ['O','8','9']]
      expect(@game.over?).to eq 'X'
    end

    it "#over? returns nil when no rows are finished" do
      @game.board =  [['X','2','X'],
                      ['4','O','O'],
                      ['O','8','9']]
      expect(@game.over?).to eq nil
    end
  end

  describe '#diag_finished' do
    before(:each) do
      @game = Game.new
    end
    
    it "#over? returns the symbol of a finished diagonal (no rows finished)" do
      @game.board =  [['X','O','O'],
                      ['4','X','O'],
                      ['O','8','X']]
      expect(@game.over?).to eq 'X'
    end

    it "#over? returns nil when no diagonals are finished" do
      @game.board =  [['X','2','X'],
                      ['4','O','O'],
                      ['O','8','9']]
      expect(@game.over?).to eq nil
    end
  end

  describe '#tied' do
    before(:each) do
      @game = Game.new
    end
    
    it "#over? returns true for finished games (no winner)" do
      @game.board =  [['O','O','X'],
                      ['X','O','O'],
                      ['O','X','X']]
      expect(@game.over?).to eq 'TIE'
    end

    it "#over? returns nil for unfinished games" do
      @game.board =  [['X','2','X'],
                      ['4','O','O'],
                      ['O','8','9']]
      expect(@game.over?).to eq nil
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

  describe "#set_player_preference" do
    before(:each) do
      @game = Game.new
    end

    context "with valid input" do
      before(:each) do
        Object.any_instance.stub(:valid_symbol?).and_return true
        @game.set_player_preference('O')
      end
      
      it "sets human's symbol" do
        expect(@game.human.symbol).to eq 'O'
      end

      it "sets AI's symbol" do
        expect(@game.ai.symbol).to eq 'X'
      end

      it "sets AI's user symbol" do
        expect(@game.ai.user_sym).to eq 'O'
      end
    end

    context "with invalid input" do
      before(:each) do
        Object.any_instance.stub(:valid_symbol?).and_return false
        @game.set_player_preference('k')
      end
      
      it "sets human's symbol" do
        expect(@game.human.symbol).to eq 'X'
      end

      it "sets AI's symbol" do
        expect(@game.ai.symbol).to eq 'O'
      end

      it "sets AI's user symbol" do
        expect(@game.ai.user_sym).to eq 'X'
      end
    end
  end

  describe "#ask_position" do
    before(:each) do
      @game = Game.new
    end

    context "with valid number" do
      it "puts the user first with 1" do
        @game.stub(:gets => "1\n")
        @game.ask_position
        expect(@game.play_order).to eq [@game.human, @game.ai]
      end

      it "puts the user first with nil entry" do
        @game.stub(:gets => "\n")
        @game.ask_position
        expect(@game.play_order).to eq [@game.human, @game.ai]
      end

      it "puts the user second with 2" do
        @game.stub(:gets => "2\n")
        @game.ask_position
        expect(@game.play_order).to eq [@game.ai, @game.human]
      end

      it "sets the user based on invalid entry" do
        @game.stub(:gets => "k\n")
        @game.ask_position
        expect(@game.play_order).to eq [@game.ai, @game.human]
      end
    end
  end
  
  describe "#winner" do
    before(:each) do
      @game = Game.new
      @game.ai.symbol = 'X'
      @game.human.symbol = 'O'
      @human = double(:human, :symbol => 'O')
      @game.stub(:ai).and_return @ai
    end

    it "returns AI when X wins" do
      @game.stub(:over?).and_return 'X'
      expect(@game.winner).to eq 'AI'
    end

    it "returns HUMAN when O wins" do
      @game.stub(:over?).and_return 'O'
      expect(@game.winner).to eq 'HUMAN'
    end

    it "returns TIE when no winner" do
      @game.stub(:over?).and_return 'TIE'
      expect(@game.winner).to eq 'TIE'
    end
  end
end