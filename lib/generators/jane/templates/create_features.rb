class CreateJaneFeatures < ActiveRecord::Migration[8.0]
  def change
    create_table :jane_features do |t|
      t.string :name, null: false
      t.string :identifier, null: false
      t.string :description
      t.timestamps
    end
    add_index :jane_features, :name, unique: true
  end
end
