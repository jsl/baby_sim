module BabySim
  class Thing

    @@all = []

    def self.all
      @@all
    end

    attr_reader :name

    def initialize name, &block
      @name    = name
      @message = nil

      instance_eval &block

      @@all << self
    end

    def color(new_color = nil)
      set_or_get(:color, new_color)
    end

    def effect(new_effect = nil)
      set_or_get(:effect, new_effect)
    end

    def count(new_count = nil)
      set_or_get(:count, new_count)
    end

    def message(new_message = nil)
      set_or_get(:message, new_message)
    end

    private

    def set_or_get(key, value)
      instance_var = :"@#{key}"
      value.nil? ? instance_variable_get(instance_var) : instance_variable_set(instance_var, value)
    end
  end
end
