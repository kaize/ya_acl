module YaAcl
  class Role
    attr_reader :name, :options
    def initialize(name, options = {})
      @name = name.to_sym
      @options = options
    end

    def to_s
      self.name
    end
  end
end