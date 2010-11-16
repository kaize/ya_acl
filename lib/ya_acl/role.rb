module YaAcl
  class Role
    attr_accessor :name, :options
    def initialize(name, options = {})
      self.name = name
      self.options = options
    end

    def to_s
      self.name
    end
  end
end