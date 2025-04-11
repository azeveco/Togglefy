require "rails/generators"
require "rails/generators/migration"

module Jane
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def copy_migrations
        migration_template "create_features.rb", "db/migrate/create_jane_features.rb"
        migration_template "create_feature_assignments.rb", "db/migrate/create_jane_feature_assignments.rb"
      end
    end
  end
end
