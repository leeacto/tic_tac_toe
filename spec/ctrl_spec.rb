require 'rspec'
require_relative '../controller'

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
  end

  describe '#get_player_order' do
    it "sets an order" do
      @ctrl = Controller.new
      @ctrl.game.stub(:gets => "1\n")
      Object.any_instance.stub(:valid_start?).and_return true
      @ctrl.get_player_order
      @ctrl.game.play_order.should be_kind_of(Array)
    end
  end

end