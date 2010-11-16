module YaAcl

  class AccessDeniedError < StandardError ; end

  class Acl
    attr_reader :roles, :resources
    attr_accessor :current_user_roles

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

    def allow?(resource_name, privilege, options = {})
      res = resource(resource_name.to_s)
      res.allow? privilege, current_user_roles, options
    end

    def check!(resource, privilege, options)
      raise AccessDeniedError.new("Access deny to '#{resource}' with privilege '#{privilege} and options '#{options}'") unless alow?(resource, privilege, options)
    end
  end
end