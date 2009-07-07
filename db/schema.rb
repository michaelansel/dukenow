# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090707155143) do

  create_table "dining_extensions", :force => true do |t|
    t.integer  "place_id"
    t.string   "logo_url"
    t.string   "more_info_url"
    t.string   "owner_operator"
    t.string   "payment_methods"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "eateries", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "operating_time_taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "operating_time_taggings", ["tag_id"], :name => "index_operating_time_taggings_on_tag_id"
  add_index "operating_time_taggings", ["taggable_id", "taggable_type", "context"], :name => "index_operating_time_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "operating_time_tags", :force => true do |t|
    t.string "name"
  end

  create_table "operating_times", :force => true do |t|
    t.integer  "place_id"
    t.integer  "opensAt"
    t.integer  "length"
    t.text     "details"
    t.date     "startDate"
    t.date     "endDate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "override",     :default => 0, :null => false
    t.integer  "days_of_week", :default => 0, :null => false
  end

  create_table "places", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "building_id"
  end

  create_table "regular_operating_times", :force => true do |t|
    t.integer  "eatery_id"
    t.integer  "opensAt"
    t.integer  "closesAt"
    t.integer  "daysOfWeek"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "special_operating_times", :force => true do |t|
    t.integer  "eatery_id"
    t.integer  "opensAt"
    t.integer  "closesAt"
    t.integer  "daysOfWeek"
    t.date     "start"
    t.date     "end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

end
