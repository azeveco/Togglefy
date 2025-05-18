# frozen_string_literal: true

class CreateTogglefyFeatureAssignments < ActiveRecord::Migration
  def change
    create_table :togglefy_feature_assignments do |t|
      t.references :feature, null: false
      t.references :assignable, polymorphic: true, null: false
      t.timestamps
    end
    add_foreign_key :togglefy_feature_assignments, :togglefy_features, column: :feature_id
    add_index :togglefy_feature_assignments, %i[feature_id assignable_type assignable_id], unique: true,
                                                                                           name: "index_togglefy_assignments_uniqueness"
  end
end
