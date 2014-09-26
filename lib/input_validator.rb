class InputValidator
  class IncorrectValue < StandardError; end
  class InvalidBuildNumber < StandardError; end

  def initialize(value_string, buildnumber_string)
    @value_string = value_string
    @buildnumber = buildnumber_string
  end

  def values
    # ensure that value is checked first
    return_value = value
    return_buildnumber = buildnumber
    [return_value, return_buildnumber]
  end

  private

  def value
    raise IncorrectValue if (@value_string != "yes" && @value_string != "no")
    @value_string == "yes"
  end

  def buildnumber
    raise InvalidBuildNumber if @buildnumber.nil?
    @buildnumber.to_i
  end
end
