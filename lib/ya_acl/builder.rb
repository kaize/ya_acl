module YaAcl
  class Builder
    attr_accessor :acl

    def self.build &block
      builder = new block
      Acl.instance = builder.acl
    end

    def initialize block
      self.acl = Acl.new
      instance_eval &block
    end

    def roles(&block)
      instance_eval &block
    end

    def asserts(&block)
      instance_eval &block
    end

    def role(name, options = {})
      acl.add_role Role.new(name, options)
    end

    def assert(name, param_names, &block)
      acl.add_assert Assert.new(name, param_names, &block)
    end

    def resources(allow, &block)
      @global_allow_role = allow
      instance_eval &block
    end

    def resource(name, allow_roles = [], &block)
      raise ArgumentError, 'Options "allow_roles" must be Array' unless allow_roles.is_a? Array
      resource_allow_roles = allow_roles << @global_allow_role
      resource = Resource.new(name)
      acl.add_resource resource
      PrivilegeProxy.new(resource.name, resource_allow_roles, acl, block)
    end

    class PrivilegeProxy
      def initialize(name, allow_roles, acl, block)
        @resource_name = name
        @allow_roles = allow_roles
        @acl = acl
        instance_eval &block
      end

      def privilege(privilege_name, roles = [], &asserts_block)
        all_allow_roles = roles | @allow_roles

        asserts = {}
        if block_given?
          asserts = PrivilegeAssertProxy.build asserts_block, all_allow_roles
        end

        all_allow_roles.each do |role|
          if asserts[role]
            asserts[role].each do |assert|
              @acl.allow(@resource_name, privilege_name, role, assert)
            end
          else
            @acl.allow(@resource_name, privilege_name, role, nil)
          end
        end
      end
    end

    class PrivilegeAssertProxy
      attr_reader :asserts

      def self.build(block, all_allow_roles)
        builder = new block, all_allow_roles
        builder.asserts
      end

      def initialize(block, all_allow_roles)
        @all_allow_roles = all_allow_roles
        @asserts = {}
        instance_eval &block
      end

      def assert(name, roles = [])
        roles = @all_allow_roles unless roles.any?
        roles.each do |role|
          @asserts[role] ||= []
          @asserts[role] << name
        end
      end
    end
  end
end
