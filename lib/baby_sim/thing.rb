module BabySim
  class Thing
    ATTRIBUTE_METHODS = [:color, :effect, :count, :message]

    @@all = []

    def self.all
      @@all
    end

    attr_reader :name

    def initialize name, &block
      @name    = name
      @message = nil
      @count   = 0
      @effect  = 0

      instance_eval &block

      @@all << self
    end

    def respond_to?(symbol)
      ATTRIBUTE_METHODS.include?(symbol) || super
    end

    def method_missing(meth, *args, &block)
      if ATTRIBUTE_METHODS.include?(meth)
        variable = :"@#{meth}"
        args.any? ? instance_variable_set(variable, args[0]) : instance_variable_get(variable)
      else
        super
      end

    end
  end
end
