require "spec_helper"
require "deciders/ci"

describe Decider::CI do
  subject(:ci) { described_class.new }

  describe "#can_i_bump?" do
    context "when the build number is the latest encountered" do
      context "when can i bump set to yes" do
        before do
          ci.set_can_i_bump(false, "everything is broken", 42)
        end

        it "says you can bump" do
          ci.set_can_i_bump(true, "build is green", 43)
          expect(ci.can_i_bump?).to be_truthy
        end
      end

      context "when can i bump is set to no" do
        before do
          ci.set_can_i_bump(true, "everything is broken", 42)
        end

        it "says that you cannot bump with a reason" do
          ci.set_can_i_bump(false, "build is red", 43)
          expect(ci.can_i_bump?).to be_falsey
          expect(ci.reason).to eq("build is red")
        end
      end
    end

    context "when the build number is not the latest encountered" do
      context "when can i bump is being set to yes is previously no" do
        before do
          ci.set_can_i_bump(false, "everything is broken", 42)
        end

        it "does nothing" do
          ci.set_can_i_bump(true, "build is green", 41)
          expect(ci.can_i_bump?).to be_falsey
        end
      end

      context "when can i bump is being set to no but is previously yes" do
        before do
          ci.set_can_i_bump(true, "EVERYTHING IS GREEEN!", 42)
        end

        it "does nothing" do
          ci.set_can_i_bump(false, "build is red", 41)
          expect(ci.can_i_bump?).to be_truthy
          expect(ci.reason).to eq("EVERYTHING IS GREEEN!")
        end
      end

      context "when the build number is 0" do
        before do
          ci.set_can_i_bump(true, "EVERYTHING IS GREEEN!", 42)
        end

        it "sets the bump state" do
          ci.set_can_i_bump(false, "build is red", 0)
          expect(ci.can_i_bump?).to be_falsey
          expect(ci.reason).to eq("build is red")
        end
      end
    end
  end
end
