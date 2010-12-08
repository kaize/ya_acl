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
      acl.roles.collect { |item| item.name.to_sym }
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
      resource_allow_roles = allow_roles << @global_allow_role

      acl.add_resource(Resource.new name, resource_allow_roles, &block)
    end
  end
end