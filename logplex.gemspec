# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logplex/version'

Gem::Specification.new do |gem|
  gem.name          = "logplex"
  gem.version       = Logplex::VERSION
  gem.authors       = ["Harold Giménez", "Heroku"]
  gem.email         = ["harold.gimenez@gmail.com"]
  gem.description   = "Publish and Consume Logplex messages"
  gem.summary       = "Publish and Consume Logplex messages"
  gem.homepage      = "https://github.com/heroku/logplex-gem"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_dependency "valcro"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rubocop"
  gem.add_development_dependency "rubocop-performance"
  gem.add_development_dependency "rubocop-rspec"
  gem.add_development_dependency "webmock"
end
