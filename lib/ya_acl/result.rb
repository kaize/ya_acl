module YaAcl
  class Result
    attr_reader :status, :assert, :role

    def initialize(status = true, role = nil, assert = nil)
      @status = status
      @assert = assert
      @role   = role
    end
  end
end