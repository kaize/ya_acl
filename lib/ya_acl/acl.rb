module YaAcl

  class AccessDeniedError < StandardError ; end

  class Acl

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
      raise "#{resource} doesn't exists" unless @resources.key? resource_name
      @resources[resource_name.to_s]
    end

    def allow?(resource_name, privilege, roles, options = {})
      res = resource(resource_name)
      res.allow? privilege, roles, options
    end

    def check!(resource, privilege, roles, options = {})
      unless allow?(resource, privilege, roles, options)
        raise AccessDeniedError.new("Access denied for '#{resource}' and privilege '#{privilege}' with options '#{options}'") #TODO another format for options
      end

      true
    end
  end
end