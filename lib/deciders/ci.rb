module Decider
  class CI
    attr_reader :reason

    def initialize
      @value == false
      @reason = "CI: no data yet"
      @build_number = 0
    end

    def can_i_bump?
      @value
    end

    def set_can_i_bump(value, reason, build_number)
      if build_number >= @build_number
        @reason = reason
        @value = value
        @build_number = build_number
      end
    end
  end
end
