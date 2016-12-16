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

  s.files         = Dir["LICENSE", "README.md", "lib/**/*", "vendor/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency "warbler", '~> 2.0.4'
  s.add_dependency "plist"
  s.add_dependency 'rubyzip', '>= 1.0.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '>= 3.0.0'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'pry'
end
