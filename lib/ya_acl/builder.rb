module YaAcl
  class Builder
    attr_accessor :acl

    def self.build &block
      builder = new
      builder.instance_eval &block
      builder.acl.freeze
      Acl.instance = builder.acl
    end

    def initialize
      self.acl = Acl.new
    end

    def roles &block
      instance_eval &block
    end

    def role(name, options = {})
      acl.add_role Role.new(name, options)
    end

    def resources(allow, &block)
      @global_allow_role = allow
      instance_eval &block
    end

    def resource(name, allow_roles = [], &block)
      raise ArgumentError, 'Options "allow_roles" must be Array' unless allow_roles.is_a? Array
      raise ArgumentError, "Role '#{@global_allow_role}' already added for resource '#{name}'" if allow_roles.include? @global_allow_role
      resource_allow_roles = allow_roles << @global_allow_role

      existing_roles = acl.roles.collect { |item| item.name.to_sym }
      if allow_roles & existing_roles != allow_roles
        raise ArgumentError, "Unknown roles #{allow_roles.inspect}"
      end

      #TODO
      proxy = ResourceProxy.new(name, resource_allow_roles, existing_roles, block)
      acl.add_resource(proxy.resource)
    end
  end
end