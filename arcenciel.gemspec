# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

require 'arcenciel/version'

Gem::Specification.new do |s|
  s.name         = 'arcenciel'
  s.version      = Arcenciel::VERSION
  s.platform     = Gem::Platform::RUBY
  s.authors      = ['Nelson Gauthier']
  s.email        = ['nelson.gauthier@gmail.com']
  s.homepage     = 'https://github.com/nelgau/arcenciel'
  s.summary      = "Declarative Monome Arc microframework"
  s.description  = "Physical knobs for virtual machines"

  s.files        = `git ls-files`.split("\n")
  s.executables  = ['arcenciel-demo']
  s.require_path = 'lib'

  s.add_runtime_dependency 'osc-ruby', '~> 1.1.1'
  s.add_runtime_dependency 'colored', '>= 1.2.0'
end
