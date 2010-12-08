module YaAcl
  class ResourceProxy

    def initialize(name, allow_roles, existing_roles, &block)
      @resource = Resource.new(name)
      @allow_roles = allow_roles
      @existing_roles = existing_roles
      instance_eval &block
    end

    def resource
      @resource
    end
    
    def method_missing(privilege, *args, &check_block)
      options = args[0] || {}
      allow = (options.delete(:allow) || []) | @allow_roles
      deny = options.delete(:deny) || []

      if (allow | deny) & @existing_roles != (allow | deny)
        raise ArgumentError, "Check roles for resource #{@resource.name} and privilege '#{privilege}'"
      end

      resource.allow(privilege, allow, options, check_block)
      resource.deny(privilege, deny, options)
    end
    alias_method :privilege, :method_missing
  end
end