require "spec_helper"
require "input_validator"

describe InputValidator do
  describe "#values" do
    it "gives a valid output for valid inputs" do
      {
        ["yes", "123"] => [true, 123],
        ["no", "123"] => [false, 123]
      }.each do |input, expected_result|
        actual_result = described_class.new(*input).values
        expect(actual_result).to eq(expected_result),
          "#values for #{input} expected to equal #{expected_result}, but got #{actual_result}"
      end
    end

    it "raises the right kind of exception for invalid inputs" do
      {
        ["blah", "123"] => InputValidator::IncorrectValue,
        [nil, "123"] => InputValidator::IncorrectValue,
        ["yes", nil] => InputValidator::InvalidBuildNumber
      }.each do |input, expected_exception|
        expect { described_class.new(*input).values }.to raise_error(expected_exception),
          "#values for input #{input} expected to raise #{expected_exception}"
      end
    end
  end
end
