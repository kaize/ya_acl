# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ya_acl/version"

Gem::Specification.new do |s|
  s.name        = "ya_acl"
  s.version     = YaAcl::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mokevnin Kirill"]
  s.email       = ["mokevnin@gmail.com"]
  s.homepage    = "http://github.com/kaize/ya_acl"
  s.summary     = %q{Yet Another ACL}
  s.description = %q{Yet Another ACL}

#  s.rubyforge_project = "ya_acl"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end
