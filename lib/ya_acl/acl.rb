module YaAcl

  class AccessDeniedError < StandardError ; end
  class AssertAccessDeniedError < AccessDeniedError ; end

  class Acl

    attr_reader :roles, :resources, :asserts

    class << self
      def instance
        @@acl
      end

      def instance=(v)
        @@acl = v
      end
    end

    def initialize()
      @acl = {}
    end

    def add_role(role)
      @roles ||= {}
      @roles[role.name] = role
    end

    def role(role_name)
      if !defined?(@roles) || !@roles[role_name.to_sym]
        raise ArgumentError, "#Role '#{role_name}' doesn't exists"
      end
      @roles[role_name.to_sym]
    end
    
    def add_resource(resource)
      @resources ||= {}
      @resources[resource.name] = resource
    end

    def resource(resource_name)
      if !defined?(@resources) || !@resources[resource_name.to_sym]
        raise ArgumentError, "#Resource '#{resource_name}' doesn't exists"
      end
      @resources[resource_name.to_sym]
    end

    def privilege(resource_name, privilege_name)
      r = resource(resource_name)
      p = privilege_name.to_sym
      unless @acl[r.name][p]
        raise ArgumentError, "Undefine privilege '#{privilege_name}' for resource '#{resource_name}'"
      end

      @acl[r.name][p]
    end

    def add_assert(assert)
      @asserts ||= {}
      @asserts[assert.name] = assert
    end

    def assert(assert_name)
      if !defined?(@asserts) || !@asserts[assert_name.to_sym]
        raise ArgumentError, "#Assert '#{assert_name}' doesn't exists"
      end
      @asserts[assert_name.to_sym]
    end

    def allow(resource_name, privilege_name, role_name, assert_name = nil)
      resource  = resource(resource_name).name
      privilege = privilege_name.to_sym
      role      = role(role_name).name

      @acl[resource] ||= {}
      @acl[resource][privilege] ||= {}
      @acl[resource][privilege][role] ||= {}
      if assert_name
        assert = assert(assert_name)
        @acl[resource][privilege][role][assert.name] = assert
      end
    end

    def check(resource_name, privilege_name, roles = [], params = {})
      a_l = privilege(resource_name, privilege_name)
      roles_for_check = a_l.keys & roles.map(&:to_sym)
      return Result.new(false) if roles_for_check.empty? # return

      role_for_result = nil
      assert_for_result = nil
      roles_for_check.each do |role|
        role_for_result = role
        asserts = a_l[role]
        return Result.new if asserts.empty? #return
        result = true
        asserts.values.each do |assert|
          assert_for_result = assert
          result = assert.allow?(params)
          break unless result
        end
        if result
          return Result.new # return
        end
      end

      Result.new(false, role_for_result, assert_for_result) # return
    end

    def allow?(resource_name, privilege_name, roles = [], params = {})
      check(resource_name, privilege_name, roles, params).status
    end

    def check!(resource_name, privilege_name, roles = [], params = {})
      result = check(resource_name, privilege_name, roles, params)
      return true if result.status
      
      message = "Access denied for '#{resource_name}', privilege '#{privilege_name}'"
      if result.assert
        raise AssertAccessDeniedError, message + ", role '#{result.role}' and assert '#{result.assert.name}'"
      else
        raise AccessDeniedError, message + " and roles '#{roles.inspect}'"
      end
    end
  end
end