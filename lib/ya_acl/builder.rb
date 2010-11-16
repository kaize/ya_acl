module YaAcl
  class Builder
    attr_accessor :acl

    def self.build &block
      builder = new
      builder.instance_eval &block
      builder.acl.freeze
      builder.acl
    end

    def initialize
      self.acl = YaAcl::Acl.new
    end

    def roles &block
      self.instance_eval &block
      self.acl.roles
    end

    def role(name, options = {})
      self.acl.add_role Role.new(name, options)
    end

    def resources(allow, &block)
      @global_allow_role = allow
      self.instance_eval &block
    end

    def resource(name, allow_roles = [], &block)
      resource_allow_roles = allow_roles << @global_allow_role
      self.acl.add_resource(Resource.new name, resource_allow_roles, &block)
    end
  end
end