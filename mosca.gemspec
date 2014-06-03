# coding: utf-8

Gem::Specification.new do |s|
  s.name        = 'mosca'
  s.version     = '0.0.1'
  s.date        = '2014-05-22'
  s.summary     = "MQTT messaging made easy"
  s.description = "A simple client for mqtt communication"
  s.authors     = ["Armando Andini"]
  s.email       = 'armando.andini@hotmail.com'
  s.files       = ["lib/mosca.rb", "lib/command_builder.rb"]
  s.homepage    = 'http://github.com/antico5/mosca'
  s.license       = 'MIT'
  s.add_dependency 'mqtt', '~> 0.2.0'
  s.add_dependency 'json', '~> 1.8.1'

end
