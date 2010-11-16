module YaAcl

  class AccessDeniedError < StandardError ; end

  class Acl
    attr_reader :roles, :resources

    def add_role(role)
      @roles ||= {}
      @roles[role.name] = role
    end

    def add_resource(resource)
      @resources ||= {}
      @resources[resource.name] = resource
    end

    def resource(resource_name)
      raise "#{resource} doesn't exists" unless resources.key? resource_name
      resources[resource_name]
    end

    def allow?(resource_name, privilege, roles, options = {})
      res = resource(resource_name.to_s)
      res.allow? privilege, roles, options
    end

    def check!(resource, privilege, roles, options)
      unless alow?(resource, privilege, roles, options)
        raise AccessDeniedError.new("Access denied for '#{resource}' and privilege '#{privilege} with options '#{options}'")
      end
    end
  end
end