module YaAcl
  class Assert
    attr_reader :name
    
    def initialize(name, &block)
      @name = name.to_sym
      @block = block
    end

    def allow?(params)
      @block.call(*params)
    end
  end
end