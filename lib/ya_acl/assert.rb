module YaAcl

  class Assert
    def initialize(&block)
      @block = block
    end
    def check(can_roles, processing_roles, params)
      @can_roles = can_roles
      @processing_roles = processing_roles

      @result = false
      instance_exec(*params, &@block)
      @result
    end

    def assert(*args)
      func = args.pop
      roles = args

      if roles != (roles & @can_roles)
        raise ArgumentError, "Not allowed for #{roles.inspect}"
      end

      @result = (@processing_roles & roles).any? ? func.call : true
    end
  end
end
