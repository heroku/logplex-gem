# frozen_string_literal: true

require_relative "lib/logplex/version"

Gem::Specification.new do |spec|
  spec.name = "logplex"
  spec.version = Logplex::VERSION
  spec.authors = ["Harold Giménez", "Heroku"]
  spec.email = ["harold.gimenez@gmail.com"]
  spec.description = "Publish and Consume Logplex messages"
  spec.summary = "Publish and Consume Logplex messages"
  spec.homepage = "https://github.com/heroku/logplex-gem"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/heroku/logplex-gem"
  spec.metadata["changelog_uri"] = "https://github.com/heroku/logplex-gem/blob/main/CHANGELOG.md"

  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "valcro"
end
