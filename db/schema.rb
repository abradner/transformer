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

ActiveRecord::Schema[8.0].define(version: 2025_07_19_090227) do
  create_table "transformations", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "transformations_yaml", null: false
    t.string "transformation_type", null: false
    t.string "version", default: "1.0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_transformations_on_name", unique: true
    t.index ["transformation_type"], name: "index_transformations_on_transformation_type"
    t.index ["version"], name: "index_transformations_on_version"
    t.check_constraint "length(name) > 0", name: "name_not_empty"
    t.check_constraint "length(transformations_yaml) > 0", name: "transformations_yaml_not_empty"
  end
end
