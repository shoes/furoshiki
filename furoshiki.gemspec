# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "furoshiki/version"

Gem::Specification.new do |s|
  s.name        = "furoshiki"
  s.version     = Furoshiki::VERSION
  s.authors     = ["Steve Klabnik"]
  s.email       = "steve@steveklabnik.com"
  s.homepage    = "http://github.com/steveklabnik/furoshiki"
  s.summary     = %q{Package and distribute applications with Ruby.}
  s.description = %q{Create .app, .exe, and $LINUX_PACKAGE versions of your application, with its own embedded Ruby.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  #s.add_dependency "gem", "version"
end
