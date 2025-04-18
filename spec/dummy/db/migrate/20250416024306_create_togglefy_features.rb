class CreateTogglefyFeatures < ActiveRecord::Migration[8.0]
  def change
    create_table :togglefy_features do |t|
      t.string :name, null: false
      t.string :identifier, null: false
      t.string :description
      t.string :tenant_id
      t.string :group
      t.string :environment
      t.integer :status, default: 0, null: false
      t.timestamps
    end
    add_index :togglefy_features, :name, unique: true
    add_index :togglefy_features, :identifier, unique: true
  end
end
