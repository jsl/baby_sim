module BabySim
  class Baby
    attr_reader :health, :color, :name
    attr_accessor :location

    def initialize
      @health   = 0
      @color    = "#999"
      @name     = 'Baby'
      @location = [15, 15]

      @encounter_messages = [ ]
    end

    def encounter(thing)
      @health += thing.effect
      @encounter_messages << thing.message unless thing.message.nil?
    end

    def last_encounter_message
      @encounter_messages.last
    end

    def status
      if (health > 5)
        "grown up"

      elsif (health > 0) && (health < 4)
        "happy"

      elsif health == 0
        "ok"

      elsif (health > -5) && (health < 0)
        "crying"

      elsif health < -4
        "dead"

      end
    end

    def grown_up?
      status == "grown up"
    end

    def dead?
      status == "dead"
    end

    def finished?
      dead? || grown_up?
    end
  end
end


