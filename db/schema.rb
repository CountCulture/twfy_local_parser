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

ActiveRecord::Schema.define(:version => 20090422141729) do

  create_table "committees", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.integer  "council_id"
    t.integer  "uid"
  end

  create_table "councils", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meetings", :force => true do |t|
    t.date     "date_held"
    t.string   "agenda_url"
    t.string   "minutes_pdf"
    t.string   "minutes_rtf"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "committee_id"
  end

  create_table "members", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "party"
    t.string   "constituency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.string   "email"
    t.string   "telephone"
    t.date     "date_elected"
    t.date     "date_left"
    t.integer  "council_id"
    t.integer  "uid"
    t.string   "title"
    t.string   "qualifications"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "member_id"
    t.integer  "committee_id"
    t.date     "date_joined"
    t.date     "date_left"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parsers", :force => true do |t|
    t.string   "title"
    t.text     "item_parser"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "attribute_parser"
  end

  create_table "scrapers", :force => true do |t|
    t.string   "url"
    t.integer  "parser_id"
    t.integer  "council_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "expected_result_class"
    t.integer  "expected_result_size"
    t.text     "expected_result_attributes"
    t.string   "result_model"
    t.string   "type"
  end

end
