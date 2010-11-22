module YaAcl
  class Resource
    
    attr_accessor :name
    
    def initialize(name, allow_roles = [], &block)
      @privilegies = {}
      self.name = name
      @allow_roles = Array(allow_roles)
      instance_eval &block
    end

    def allow?(privilege, roles, params = [], options = {})
      p = privilege.to_sym
      r = Array(roles).compact.collect(&:to_sym)
      unless @privilegies[p]
        raise ArgumentError, "Unknown '#{p}' privilege for resource '#{name}'"
      end
      key = privilege_key(options)
      key = privilege_key unless @privilegies[p][key]

      return false unless @privilegies[p][key]
      return false if (@privilegies[p][key][:roles] & r || []).empty?

      privilege_accert = @privilegies[p][key][:assert]
      if privilege_accert
        @processing_privilege = privilege
        @processing_key = key
        @processing_roles = r
        if false == privilege_accert.call(*params)
          return false
        end
      end

      true
    end

    def allow(privilege, roles, options = {}, assert_block = nil)
      p = privilege.to_sym
      @privilegies[p] ||= {}
      r = roles.collect(&:to_sym)
      key = privilege_key(options)
      @privilegies[p][key] ||= {}
      @privilegies[p][key][:roles] = (@privilegies[p][key][:roles] || []) | r
      @privilegies[p][key][:assert] = assert_block
    end

    def deny(privilege, roles, options = {})
      p = privilege.to_sym
      @privilegies[p] ||= {}
      r = roles.collect(&:to_sym)
      key = privilege_key(options)
      @privilegies[p][key] ||= {}
      @privilegies[p][key][:roles] = (@privilegies[p][key][:roles] || []) - r
    end

    def method_missing(privilege, *args, &block)
      access = args[0] || {}
      allow = (access[:allow] || []) | @allow_roles
      deny = access[:deny] || []

      options = args[1] || {}
      
      allow(privilege, allow, options, block)
      deny(privilege, deny, options)
    end
    alias_method :privilege, :method_missing

    private
      def privilege_key(options = {})
        options.any? ? options.sort.to_s : :default
      end
      
      def assert(*roles, &block)
        can_roles = @privilegies[@processing_privilege][@processing_key][:roles]
        if roles != can_roles & roles
          raise ArgumentError, "Not allowed for #{roles.inspect}"
        end
        return true unless (@processing_roles & roles).any?
        return block.call
      end
  end
end