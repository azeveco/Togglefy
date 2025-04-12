class CreateJaneFeatures < ActiveRecord::Migration[8.0]
  def change
    create_table :jane_features do |t|
      t.string :name, null: false
      t.string :identifier, null: false
      t.string :description
      t.string :tenant
      t.string :group
      t.string :environment
      t.integer :status, default: 0, null: false
      t.timestamps
    end
    add_index :jane_features, :name, unique: true
    add_index :jane_features, :identifier, unique: true
  end
end
