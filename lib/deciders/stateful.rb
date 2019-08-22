module Decider
  class Stateful
    def initialize(client)
      @client = client
    end

    def can_i_bump?
      @client[:canibump].find(:name => 'status').first[:value] || false
    end

    def reason
      @client[:canibump].find(:name => 'status').first[:reason] || 'no reason yet'
    end

    def build_number
      0
    end

    def set_can_i_bump(value, reason)
      @client[:canibump].find_one_and_update({ :name => 'status' }, { :name => 'status' , :reason => reason, :value => value })
    end
  end
end
