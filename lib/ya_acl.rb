module YaAcl
  autoload :Acl, 'ya_acl/acl'
  autoload :Role, 'ya_acl/role'
  autoload :Resource, 'ya_acl/resource'
  autoload :Assert, 'ya_acl/assert'
  autoload :Result, 'ya_acl/result'
  autoload :Builder, 'ya_acl/builder'

  class AccessDeniedError < RuntimeError ; end
  class AssertAccessDeniedError < AccessDeniedError ; end
end
