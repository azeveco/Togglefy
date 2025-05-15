# frozen_string_literal: true

require "rails/generators"
require "rails/generators/migration"

module Togglefy
  # The Generators module contains Rails generators for setting up and managing Togglefy in a Rails application.
  module Generators
    # The InstallGenerator class is responsible for setting up the necessary migrations
    # for the Togglefy gem in a Rails application. It generates migration files for
    # creating features and feature assignments.
    #
    # @example Usage
    #   rails generate togglefy:install
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      # Sets the source directory for templates used by the generator.
      source_root File.expand_path("templates", __dir__)

      # Generates a migration file numbered with the current timestamp.
      #
      # @param _path [String] The path to the migration file.
      # @return [String] The migration number formatted as YYYYMMDDHHMMSS.
      # @example
      #   def self.next_migration_number(_path)
      #     Time.now.utc.strftime("%Y%m%d%H%M%S")
      #   end
      #   # => "20231005123456"
      # @note This method is used to ensure that the migration file has a unique
      #       timestamp, preventing conflicts with other migrations.
      def self.next_migration_number(_path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      # Copies the migration templates to the Rails application's db/migrate directory.
      #
      # @return [void]
      # @note The `sleep` call ensures that the second migration file gets a unique timestamp.
      def copy_migrations
        if Rails::VERSION::MAJOR >= 5
          migration_template "create_features.rb", "db/migrate/create_togglefy_features.rb"
          sleep 1
          migration_template "create_feature_assignments.rb", "db/migrate/create_togglefy_feature_assignments.rb"
        else
          migration_template "older_rails_create_features.rb", "db/migrate/create_togglefy_features.rb"
          sleep 1
          migration_template "older_rails_create_feature_assignments.rb", "db/migrate/create_togglefy_feature_assignments.rb" # rubocop:disable Layout/LineLength
        end
      end
    end
  end
end
