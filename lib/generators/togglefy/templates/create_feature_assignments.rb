class CreateTogglefyFeatureAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :togglefy_feature_assignments do |t|
      t.references :feature, null: false, foreign_key: { to_table: :togglefy_features }
      t.references :assignable, polymorphic: true, null: false
      t.timestamps
    end
    add_index :togglefy_feature_assignments, [:feature_id, :assignable_type, :assignable_id], unique: true, name: "index_togglefy_assignments_uniqueness"
  end
end