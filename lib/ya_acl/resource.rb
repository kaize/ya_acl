module YaAcl
  class Resource
    
    attr_accessor :name
    
    def initialize(name)
      @privilegies = {}
      self.name = name
    end

    def allow?(privilege, roles, params = [], options = {})
      raise ArgumentError, 'Params must be an Array' unless params.kind_of?(Array)
      
      p = privilege.to_sym
      r = Array(roles).compact.collect(&:to_sym)
      unless @privilegies[p]
        raise ArgumentError, "Unknown '#{p}' privilege for resource '#{name}'"
      end
      key = privilege_key(options)
      key = privilege_key unless @privilegies[p][key]
      
      return false unless @privilegies[p][key]
      return false if (@privilegies[p][key][:roles] & r || []).empty?

      assert = @privilegies[p][key][:assert]
      if assert
        can_roles = @privilegies[p][key][:roles]
        if false == assert.check(can_roles, r, params)
          return false
        end
      end

      true
    end

    def allow(privilege, roles, options = {}, &block)
      p = privilege.to_sym
      @privilegies[p] ||= {}
      r = roles.collect(&:to_sym)
      key = privilege_key(options)
      @privilegies[p][key] ||= {}
      @privilegies[p][key][:roles] = (@privilegies[p][key][:roles] || []) | r
      @privilegies[p][key][:assert] = block && Assert.new(&block) || nil
    end

    def deny(privilege, roles, options = {})
      p = privilege.to_sym
      @privilegies[p] ||= {}
      r = roles.collect(&:to_sym)
      key = privilege_key(options)
      @privilegies[p][key] ||= {}
      @privilegies[p][key][:roles] = (@privilegies[p][key][:roles] || []) - r
    end

    private
      def privilege_key(options = {})
        options.any? ? options.sort.to_s : :default
      end
  end
end