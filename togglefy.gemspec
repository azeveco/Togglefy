# frozen_string_literal: true

require_relative "lib/togglefy/version"

Gem::Specification.new do |spec|
  spec.name = "togglefy"
  spec.version = Togglefy::VERSION
  spec.authors = ["Gabriel Azevedo"]
  spec.email = ["gazeveco@gmail.com"]

  spec.summary = "Simple and open source Feature Management."
  spec.description = "Togglefy is a feature management Rails gem to help you control which features an user or a group has access to."
  spec.homepage = "https://github.com/azeveco/Togglefy"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/azeveco/Togglefy"
  spec.metadata["changelog_uri"] = "https://github.com/azeveco/Togglefy/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  File.basename(__FILE__)
  spec.files = Dir.glob("lib/**/*") +
               Dir.glob("app/**/*") +
               Dir.glob("config/**/*") +
               Dir.glob("spec/**/*") +
               %w[LICENSE.txt README.md Rakefile togglefy.gemspec]

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bootsnap", "~> 1.17"
  spec.add_development_dependency "database_cleaner-active_record"
  spec.add_development_dependency "rails", "~> 8.0.2"
  spec.add_development_dependency "rspec-rails", "~> 7.1.1"
  spec.add_development_dependency "sqlite3", ">= 2.1"
end
