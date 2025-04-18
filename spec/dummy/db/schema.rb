# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_16_024317) do
  create_table "togglefy_feature_assignments", force: :cascade do |t|
    t.integer "feature_id", null: false
    t.string "assignable_type", null: false
    t.integer "assignable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignable_type", "assignable_id"], name: "index_togglefy_feature_assignments_on_assignable"
    t.index ["feature_id", "assignable_type", "assignable_id"], name: "index_togglefy_assignments_uniqueness", unique: true
    t.index ["feature_id"], name: "index_togglefy_feature_assignments_on_feature_id"
  end

  create_table "togglefy_features", force: :cascade do |t|
    t.string "name", null: false
    t.string "identifier", null: false
    t.string "description"
    t.string "tenant_id"
    t.string "group"
    t.string "environment"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_togglefy_features_on_identifier", unique: true
    t.index ["name"], name: "index_togglefy_features_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "togglefy_feature_assignments", "togglefy_features", column: "feature_id"
end
