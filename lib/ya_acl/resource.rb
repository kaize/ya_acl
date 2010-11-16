module YaAcl
  class Resource
    attr_accessor :name
    
    def initialize(name, &block)
      self.name = name
      self.instance_eval &block
    end

    def allow?(privilege, roles, options = {})
      unless @privilegies[privilege]
        raise InvalidArgument.new "Unknown #{privilege} for resource '#{name}'"
      end
      resource_roles = @privilegies[privilege][privilege_key(options)]
      unless resource_roles
        resource_roles = @privilegies[privilege][privilege_key]
      end
      return false if (resource_roles & [roles]).empty?

      true
    end

    def allow(privilege, roles, options = {})
      @privilegies ||= {}
      @privilegies[privilege] ||= {}
      
      key = privilege_key(options)
      @privilegies[privilege][key] = (@privilegies[privilege][key] || []) | roles
    end

    def deny(privilege, roles, options = {})
      @privilegies ||= {}
      @privilegies[privilege] ||= {}

      key = privilege_key(options)
      @privilegies[privilege][key] = (@privilegies[privilege][key] || []) - roles
    end

    def method_missing(privilege, *args)
      roles = args.first # allow, deny
      options = args[1] || {}
      allow(privilege, roles[:allow] || [], options)
      deny(privilege, roles[:deny] || [], options)
    end

    private
      def privilege_key(options = {})
        options.any? ? options.sort.to_s : :default
      end
  end
end