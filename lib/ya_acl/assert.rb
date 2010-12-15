module YaAcl

  class Assert
    def initialize(&block)
      @block = block
    end
    def check(can_roles, processing_roles, params)
      @can_roles = can_roles
      @processing_roles = processing_roles

      @results = {}
      @processing_roles.each {|role| @results[role] = true }
      instance_exec(*params, &@block)

      @results.values.each do |result|
        return true if result
      end

      false
    end

    def assert(roles, func)
      unless roles.is_a? Array
        raise ArgumentError, "Expected roles array for asserts, but given '#{roles.inspect}'"
      end
      if roles != (roles & @can_roles)
        raise ArgumentError, "Not allowed for #{roles.inspect} (Check roles for your asserts)"
      end

      roles_for_assert = @processing_roles & roles
      if roles_for_assert.any?
        result = func.call
        roles_for_assert.each do |role|
          @results[role] = result if @results[role] 
        end
      end
    end
  end
end
