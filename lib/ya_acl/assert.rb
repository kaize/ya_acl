module YaAcl

  class Assert
    def initialize(&block)
      @block = block
    end
    def check(can_roles, processing_roles, params)
      @can_roles = can_roles
      @processing_roles = processing_roles

      @result = true
      instance_exec(*params, &@block)
      @result
    end

    def assert(roles, func)
      unless roles.is_a? Array
        raise ArgumentError, "Expected roles array for asserts, but given '#{roles.inspect}'"
      end
      if roles != (roles & @can_roles)
        raise ArgumentError, "Not allowed for #{roles.inspect} (Check roles for your asserts)"
      end

      @result = func.call if (@processing_roles & roles).any? && @result
    end
  end
end
