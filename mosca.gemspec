# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'mosca/version'

Gem::Specification.new do |s|
  s.name        = 'mosca'
  s.version     = Mosca::VERSION
  s.summary     = "MQTT messaging made easy"
  s.description = "A simple client for mqtt communication"
  s.authors     = ["Armando Andini"]
  s.email       = 'armando.andini@hotmail.com'
  s.license     = 'MIT'
  s.homepage    = 'http://github.com/antico5/mosca'

  s.files         = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency 'mqtt', '~> 0.2.0'
  s.add_dependency 'json', '~> 1.8.1'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'
end
