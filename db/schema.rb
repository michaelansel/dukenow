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

ActiveRecord::Schema.define(:version => 20090314001220) do

  create_table "eateries", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "operating_times", :force => true do |t|
    t.integer  "place_id"
    t.integer  "opensAt"
    t.integer  "closesAt"
    t.text     "details"
    t.integer  "flags"
    t.date     "startDate"
    t.date     "endDate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
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

end
