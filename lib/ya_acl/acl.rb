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
      raise ArgumentError, "#Role '#{role_name}' doesn't exists" if !defined?(@roles) || !@roles[role_name.to_sym]
      @roles[role_name.to_sym]
    end
    
    def add_resource(resource)
      @resources ||= {}
      @resources[resource.name] = resource
    end

    def resource(resource_name)
      raise ArgumentError, "#Resource '#{resource_name}' doesn't exists" if !defined?(@resources) || !@resources[resource_name.to_sym]
      @resources[resource_name.to_sym]
    end

    def add_assert(assert)
      @asserts ||= {}
      @asserts[assert.name] = assert
    end

    def assert(assert_name)
      raise ArgumentError, "#Assert '#{assert_name}' doesn't exists" if !defined?(@asserts) || !@asserts[assert_name.to_sym]
      @asserts[assert_name.to_sym]
    end

    def allow(resource_name, privilege_name, role_name, assert_name = nil, options = {})
      resource  = resource(resource_name).name
      privilege = privilege_name.to_sym
      role      = role(role_name).name
      key       = build_key(options)

      @acl[resource] ||= {}
      @acl[resource][privilege] ||= {}
      @acl[resource][privilege][key] ||= {}
      @acl[resource][privilege][key][role] ||= {}
      if assert_name
        assert = assert(assert_name)
        @acl[resource][privilege][key][role][assert.name] = assert
      end
    end

    def check(resource_name, privilege_name, roles = [], params = [], options = {})
      a_l = access_list(resource_name, privilege_name, options)
      return Result.new(false) if a_l.nil?
      roles_for_check = a_l.keys & roles.map(&:to_sym)
      return Result.new(false) if roles_for_check.empty? # return

      role_for_result = nil
      assert_for_result = nil
      roles_for_check.each do |role|
        role_for_result = role
        asserts = a_l[role]
        return Result.new if asserts.empty? #return
        assert = nil
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

      return Result.new(false, role_for_result, assert_for_result) # return
    end

    def allow?(resource_name, privilege_name, roles = [], params = [], options = {})
      check(resource_name, privilege_name, roles, params, options).status
    end

    def check!(resource_name, privilege_name, roles = [], params = [], options = {})
      result = check(resource_name, privilege_name, roles, params, options)
      return true if result.status
      
      message = "Access denied for '#{resource_name}', privilege '#{privilege_name}', options '#{options.inspect}'"
      if result.assert
        raise AssertAccessDeniedError, message + ", role '#{result.role}' and assert '#{result.assert.name}'"
      else
        raise AccessDeniedError, message + " and roles '#{roles.inspect}'"
      end
    end

    protected

    def access_list(resource_name, privilege_name, options = {})
      r = resource(resource_name)
      p = privilege_name.to_sym
      key = build_key(options)

      unless @acl[r.name][p]
        raise ArgumentError, "Undefine privilege '#{privilege_name}' for resource '#{resource_name}'"
      end

      @acl[r.name][p][key] || @acl[r.name][p][:default]
    end
    
    def build_key(options = {})
      options.any? ? options.sort.to_s : :default
    end
  end
end