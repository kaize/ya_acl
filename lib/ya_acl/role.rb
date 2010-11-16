module YaAcl
  class Role
    attr_accessor :name, :options
    def initialize(name, options = {})
      self.name = name
      self.options = options
    end
  end
end