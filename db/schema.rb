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

ActiveRecord::Schema.define(:version => 20100227152421) do

  create_table "firms", :force => true do |t|
    t.string   "name"
    t.string   "town"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends", :id => false, :force => true do |t|
    t.integer  "member_id",        :null => false
    t.integer  "member_id_friend", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invites", :force => true do |t|
    t.integer  "member_id",                           :null => false
    t.integer  "member_id_target",                    :null => false
    t.string   "code"
    t.text     "message"
    t.boolean  "is_accepted",      :default => false
    t.datetime "accepted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "line_professional_curriculum", :force => true do |t|
    t.integer  "member_id"
    t.integer  "firm_id"
    t.date     "beginning_year"
    t.date     "ending_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", :force => true do |t|
    t.string   "login",                     :limit => 40,  :default => "",        :null => false
    t.string   "first_name",                :limit => 100, :default => "",        :null => false
    t.string   "last_name",                 :limit => 100, :default => "",        :null => false
    t.string   "civil_state"
    t.string   "town"
    t.string   "zipcode"
    t.string   "region"
    t.string   "state",                                    :default => "pending"
    t.string   "email",                     :limit => 100
    t.string   "activation_code"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
  end

  add_index "members", ["login"], :name => "index_members_on_login", :unique => true

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "promotion_curriculum", :force => true do |t|
    t.integer  "member_id"
    t.integer  "school_id"
    t.date     "beginning_year"
    t.date     "ending_year"
    t.string   "degree_obtain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "promotions", :force => true do |t|
    t.string   "degree"
    t.date     "year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.string   "town"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
