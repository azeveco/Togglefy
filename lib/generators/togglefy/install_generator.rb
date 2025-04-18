# frozen_string_literal: true

require "rails/generators"
require "rails/generators/migration"

module Togglefy
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def self.next_migration_number(_path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def copy_migrations
        migration_template "create_features.rb", "db/migrate/create_togglefy_features.rb"
        sleep 1.5
        migration_template "create_feature_assignments.rb", "db/migrate/create_togglefy_feature_assignments.rb"
      end
    end
  end
end
