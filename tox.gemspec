# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tox/version'

Gem::Specification.new do |spec|
  spec.name          = 'tox'
  spec.version       = Tox::VERSION
  spec.authors       = ['Mattias Putman']
  spec.email         = ['mattias.putman@gmail.com']

  spec.summary       = %q{Parses and Renders XML using a template}
  spec.homepage      = 'https://www.github.com/piesync/tox'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'ox', '!= 2.9.3'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
