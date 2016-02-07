# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_resource/version'

Gem::Specification.new do |spec|
  spec.name    = 'easy_resource'
  spec.version = EasyResource::VERSION.dup
  spec.authors = ['Jan Uhlar']

  spec.summary  = %q{Makes it easy to handle CRUD actions in controller}
  spec.homepage = 'http://github.com/ciihla/easy_resource'
  spec.license  = 'MIT'

  spec.files         = Dir['lib/**/*', 'README.md', 'MIT-LICENSE']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_dependency 'activesupport', '>= 3.2', '< 5'
  spec.add_dependency 'responders'
end
