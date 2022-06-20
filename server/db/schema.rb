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

ActiveRecord::Schema[7.0].define(version: 2022_06_12_102626) do
  create_table "aquaria", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "data", force: :cascade do |t|
    t.integer "aquarium_id", null: false
    t.integer "sensor_id", null: false
    t.string "value"
    t.date "dataCapture"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aquarium_id"], name: "index_data_on_aquarium_id"
    t.index ["sensor_id"], name: "index_data_on_sensor_id"
  end

  create_table "sensors", force: :cascade do |t|
    t.string "name"
    t.string "guid"
    t.string "unitOfMeasure"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "data", "aquaria"
  add_foreign_key "data", "sensors"
end