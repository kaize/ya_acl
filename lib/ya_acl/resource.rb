module YaAcl
  class Resource
    attr_accessor :name
    
    def initialize(name, allow_roles = [],  &block)
      self.name = name
      @allow_roles = Array(allow_roles)
      self.instance_eval &block
    end

    def allow?(privilege, roles, options = {})
      p = privilege.to_sym
      r = Array(roles).collect(&:to_sym)
      unless @privilegies[p]

        raise ArgumentError.new "Unknown '#{p}' privilege for resource '#{name}'"
      end
      resource_roles = @privilegies[p][privilege_key(options)]
      unless resource_roles
        resource_roles = @privilegies[p][privilege_key]
      end
      return false if (resource_roles & r).empty?

      true
    end

    def allow(privilege, roles, options = {})
      p = privilege.to_sym
      @privilegies ||= {}
      @privilegies[p] ||= {}
      r = roles.collect(&:to_sym)
      key = privilege_key(options)
      @privilegies[p][key] = (@privilegies[p][key] || []) | r
    end

    def deny(privilege, roles, options = {})
      p = privilege.to_sym
      @privilegies ||= {}
      @privilegies[p] ||= {}
      r = roles.collect(&:to_sym)
      key = privilege_key(options)
      @privilegies[p][key] = (@privilegies[p][key] || []) - r
    end

    def method_missing(privilege, *args)
      roles = args.first || {} # allow, deny
      if @allow_roles.any?
        roles[:allow] ||= []
        roles[:allow] |= @allow_roles
      end
      if roles
        options = args[1] || {}
        allow(privilege, roles[:allow] || [], options)
        deny(privilege, roles[:deny] || [], options)
      end
    end

    private
      def create_privilege(privilege)
        
      end
      def privilege_key(options = {})
        options.any? ? options.sort.to_s : :default
      end
  end
end