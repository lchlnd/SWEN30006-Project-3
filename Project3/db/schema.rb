# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150514042005) do

  create_table "datapoints", force: :cascade do |t|
    t.float    "value"
    t.string   "type"
    t.integer  "reading_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "datapoints", ["reading_id"], name: "index_datapoints_on_reading_id"

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.integer  "position_id"
    t.integer  "postcode_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "locations", ["position_id"], name: "index_locations_on_position_id"
  add_index "locations", ["postcode_id"], name: "index_locations_on_postcode_id"

  create_table "positions", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "postcodes", force: :cascade do |t|
    t.integer  "code"
    t.integer  "position_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "postcodes", ["position_id"], name: "index_postcodes_on_position_id"

  create_table "predicted_datapoints", force: :cascade do |t|
    t.float    "value"
    t.string   "type"
    t.float    "probability"
    t.integer  "prediction_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "predicted_datapoints", ["prediction_id"], name: "index_predicted_datapoints_on_prediction_id"

  create_table "predicted_rainfalls", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "predicted_temperatures", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "predicted_wind_directions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "predicted_wind_speeds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "predictions", force: :cascade do |t|
    t.integer  "timeframe"
    t.integer  "position_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "predictions", ["position_id"], name: "index_predictions_on_position_id"

  create_table "rainfalls", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "readings", force: :cascade do |t|
    t.integer  "location_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "readings", ["location_id"], name: "index_readings_on_location_id"

  create_table "temperatures", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wind_directions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wind_speeds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
