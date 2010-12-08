module YaAcl

  class AccessDeniedError < StandardError ; end

  class Acl

    def self.instance
      @@acl
    end

    def self.instance=(v)
      @@acl = v
    end

    def roles
      @roles.values
    end

    def add_role(role)
      @roles ||= {}
      @roles[role.name] = role
    end

    def add_resource(resource)

      @resources ||= {}
      @resources[resource.name] = resource
    end

    def resource(resource_name)
      raise ArgumentError, "#Resource '#{resource_name}' doesn't exists" unless @resources.key? resource_name
      @resources[resource_name.to_s]
    end

    def allow?(resource_name, privilege, roles, params = [], options = {})
      res = resource(resource_name)
      res.allow? privilege, roles, params, options
    end

    def check!(resource, privilege, roles, params = [], options = {})
      unless allow?(resource, privilege, roles, params, options)
        raise AccessDeniedError, "Access denied for '#{resource}' and privilege '#{privilege}' with options '#{options.inspect}'"
      end

      true
    end
  end
end