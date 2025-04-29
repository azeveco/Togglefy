# frozen_string_literal: true

rails_version = "#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"

class CreateTogglefyFeatureAssignments < ActiveRecord::Migration[rails_version]
  def change
    create_table :togglefy_feature_assignments do |t|
      t.references :feature, null: false, foreign_key: { to_table: :togglefy_features }
      t.references :assignable, polymorphic: true, null: false
      t.timestamps
    end
    add_index :togglefy_feature_assignments, %i[feature_id assignable_type assignable_id], unique: true,
                                                                                           name: "index_togglefy_assignments_uniqueness"
  end
end
