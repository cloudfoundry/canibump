require "spec_helper"
require "final_decider"

describe FinalDecider do
  subject(:decider) { described_class.new([]) }

  describe "#can_i_bump?" do

    context "when no deciders are present" do
      it "should return false when there are no deciders" do
        expect(decider.can_i_bump?).to eq false
      end
    end

    context "when we have deciders" do
      let(:ci) { Decider::CI.new }
      let(:deciders) { [ci] }
      let(:decider) { described_class.new deciders}

      context "when any of the concrete deciders return false" do
        before do
          allow(ci).to receive(:can_i_bump?).and_return(false)
        end

        it "should return false" do
          expect(decider.can_i_bump?).to eq false
        end
      end

      context "when ALL of the concrete deciders return true" do
        before do
          allow(ci).to receive(:can_i_bump?).and_return(true)
        end

        it "should return true only" do
          expect(decider.can_i_bump?).to eq true
        end
      end
    end
  end
end
