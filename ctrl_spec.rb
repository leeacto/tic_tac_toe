require 'rspec'
require_relative 'controller'

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end

describe Controller do
  it "Exists" do
    expect(Controller.new).to be_true
  end

  describe 'Initialize' do
    before(:each) do
      @ctrl = Controller.new
    end

    it "has a Game model" do
      expect(@ctrl.game).to be_kind_of(Game)
    end

    it "has a View" do
      expect(@ctrl.view).to be_kind_of(View)
    end

    describe 'Turn_Count' do
      it 'has a turn counter' do
        expect(@ctrl.turn_count).to be_kind_of(Fixnum)
      end
    end
  end

  describe '#symbol_preference' do
    before(:each) do
      @ctrl = Controller.new
    end

    it "has a symbol preference" do
      @ctrl.should respond_to(:symbol_preference)
    end

    describe "setting symbol" do
      context "successfully" do
        it "takes X" do
          @ctrl.stub(:gets => "X\n")
          @ctrl.symbol_preference
          @ctrl.user_sym.should == 'X'
        end

        it "takes O" do
          @ctrl.stub(:gets => "O\n")
          @ctrl.symbol_preference
          @ctrl.user_sym.should == 'O'
        end

        it "takes lower case" do
          @ctrl.stub(:gets => "x\n")
          @ctrl.symbol_preference
          @ctrl.user_sym.should == 'X'
        end

        it "sets computer to opposite" do
          @ctrl.stub(:gets => "O\n")
          @ctrl.symbol_preference
          @ctrl.ai_sym.should == 'X'
        end
      end

      context "unsuccessfully" do
        it "defaults to X" do
          @ctrl.stub(:gets).and_return("j\n")
          @ctrl.symbol_preference
          @ctrl.user_sym.should eq "X"
        end
      end
    end
  end

  describe '#user_start' do
    before(:each) do
      @ctrl = Controller.new
      @ctrl.stub(:gets => "O\n")
      @ctrl.symbol_preference
    end

    it "has a start preference method" do
      @ctrl.should respond_to(:user_start)
    end

    describe "opting to start" do
      context "first" do
        before(:each) do
          @ctrl.stub(:gets => "1\n")
          @ctrl.user_start
        end

        it "sets the correct value" do
          @ctrl.user_begin.should eq 1
        end

        it "stages the user's turn" do
          pending
        end
      end

      context "second" do
        before(:each) do
          @ctrl.stub(:gets => "2\n")
          @ctrl.user_start
        end

        it "sets the correct value" do
          @ctrl.user_begin.should eq 2
        end

        it "stages the computer's turn" do
          pending
          #Maybe test that the board has an element 
          #and then it's the player's turn
        end
      end

      context "with invalid entry" do
        it "assigns a start based on first letter" do
          @ctrl.stub(:gets => "k\n")
          @ctrl.user_start
          @ctrl.user_begin.should eq 2
        end
      end
    end
  end

  describe '#user_turn' do
    before(:each) do
      @ctrl = Controller.new
      @ctrl.user_sym = 'O'
      @ctrl.ai_sym = 'X'
    end

    it "has a turns method" do
      @ctrl.should respond_to(:user_turn)
    end

    describe "when user is first" do
      before(:each) do
        @ctrl.user_begin = 1
      end

      context "receiving selection" do
        describe "with valid option" do
          it "updates game.board" do
            @ctrl.stub(:gets => "5\n")
            @ctrl.user_turn
            @ctrl.game.board[1][1].should eq 'O'
          end
        end

        # describe "with invalid option" do
        #   it "does not update game.board" do
        #     pending
        #     #How do I break out of infinite loop?
        #     # @ctrl.stub(:gets => "10\n")
        #     # @ctrl.turns
        #     # @ctrl.game.open_spots == ('1'..'9').to_a
        #   end
        # end
      end
    end
  end

  describe "#ai_turn" do
    before(:each) do
      @ctrl = Controller.new
      @ctrl.user_sym = 'O'
      @ctrl.ai_sym = 'X'
      @ctrl.user_begin = 1
    end

    it "has a an ai_turn method" do
      @ctrl.should respond_to(:ai_turn)
    end

    describe "choosing positions" do
      context "obvious wins" do
        it "on row" do
          @ctrl.game.board = [['X','X','3'],
                              ['O','5','6'],
                              ['7','O','9']]
          expect(@ctrl.ai_turn).to eq 'X'
        end

        it "on column" do
          @ctrl.game.board = [['X','2','3'],
                              ['X','5','O'],
                              ['7','O','9']]
          expect(@ctrl.ai_turn).to eq 'X'
        end

        it "on diagonal" do
          @ctrl.game.board = [['X','2','3'],
                              ['4','X','O'],
                              ['7','O','9']]
          expect(@ctrl.ai_turn).to eq 'X'
        end
      end

      context "must block" do
        it "on row" do
          @ctrl.game.board = [['O','O','3'],
                              ['X','5','6'],
                              ['7','X','9']]
          expect(@ctrl.ai_turn).to eq 'X'
        end
      end
    end
  end

  describe "#best_move" do
    before(:each) do
      @ctrl = Controller.new
      @ctrl.ai_sym = 'O'
      @ctrl.user_sym = 'X'
    end

    it "returns the best position when it can win" do
      @ctrl.game.board = [['O','X','O'],
                          ['4','X','6'],
                          ['O','8','X']]
      expect(@ctrl.best_move(@ctrl.game, true)).to eq ['O']
    end
  end

  describe '#simulate_user' do
    before(:each) do
      @ctrl = Controller.new
      @ctrl.ai_sym = 'O'
      @ctrl.user_sym = 'X'
    end

    it "takes the win when it can" do
      @ctrl.game.board = [['O','2','X'],
                          ['4','5','6'],
                          ['7','O','X']]
      expect(@ctrl.simulate_user(@ctrl.game)).to eq 'X'
    end

    it "returns an array of outcomes" do
      @ctrl.game.board = [['O','X','3'],
                          ['X','5','6'],
                          ['O','O','X']]
      expect(@ctrl.simulate_user(@ctrl.game).flatten).to eq ['TIE', 'TIE', 'X']
    end
  end

  describe '#create_and_update_board' do
    before(:each) do
      @ctrl = Controller.new
      @ctrl.ai_sym = 'O'
      @ctrl.user_sym = 'X'
      @ctrl.game.board = [['O','X','O'],
                          ['4','5','6'],
                          ['O','8','X']]
    end

    it "returns a new board with updated cell" do
      new_game = @ctrl.create_and_update_board(@ctrl.game.board, 4, 'X')
      expect(new_game.board[1][0]).to eq 'X'
    end
  end

  describe '#ai_turn' do
    it "return the best position two moves out" do
      @ctrl = Controller.new
      @ctrl.ai_sym = 'O'
      @ctrl.user_sym = 'X'
      @ctrl.game.board = [['O','X','O'],
                          ['4','5','6'],
                          ['7','8','X']]
      @ctrl.ai_turn
      expect(@ctrl.game.board).to eq [['O','X','O'],
                                      ['4','5','6'],
                                      ['O','8','X']]
    end
  end

  describe '#best_option' do
    before(:each) do
      @ctrl = Controller.new
      @ctrl.ai_sym = 'O'
      @ctrl.user_sym = 'X'
      @outcomes = {"4"=>[["TIE", "TIE"]], 
                   "5"=>[["TIE", "TIE"]], 
                   "6"=>[["TIE", "TIE", "TIE", "TIE", "TIE", "TIE", "TIE", "TIE", "X"]], 
                   "7"=>[["O"]], 
                   "8"=>[["TIE", "TIE", "TIE", "TIE", "TIE", "TIE", "TIE", "TIE", "TIE", "TIE", "O", "TIE", "TIE", "TIE", "TIE", "TIE", "TIE"]]}
    end
    
    it "selects any option with all wins" do
      expect(@ctrl.best_option(@outcomes)).to eq '7'
    end

    it "selects best highest pct if none are obvious" do
      @outcomes.delete('7')
      expect(@ctrl.best_option(@outcomes)).to eq '4'
    end
  end
end