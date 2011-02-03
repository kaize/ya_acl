module YaAcl
  class Assert
    attr_reader :name
    
    def initialize(name, param_names, &block)
      @name = name.to_sym
      @param_names = param_names
      @block = block

      @param_names.each do |name|
        self.class.send :attr_accessor, name
      end
    end

    def allow?(params)
      if @param_names != (@param_names & params.keys)
        raise "Params for assert '#{name}': #{@param_names.inspect}"
      end

      @param_names.each do |name|
        self.send "#{name}=", params[name]
      end
      
      instance_eval &@block
    end
  end
end