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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120917193738) do

  create_table "accounts", :force => true do |t|
    t.string  "name",                                      :default => "",  :null => false
    t.integer "business_id"
    t.decimal "balance",     :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.string  "currency"
  end

  create_table "agents", :force => true do |t|
    t.string  "name",        :default => "Unknown", :null => false
    t.integer "business_id"
  end

  create_table "businesses", :force => true do |t|
    t.string   "name",       :default => "",         :null => false
    t.integer  "owner_id",                           :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "type",       :default => "Personal"
  end

  create_table "contacts", :force => true do |t|
    t.string  "name",        :default => "Unknown", :null => false
    t.integer "business_id"
  end

  create_table "enrollments", :force => true do |t|
    t.integer "membership_id"
    t.decimal "value",         :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.integer "agent_id"
  end

  create_table "enrollments_transactions", :force => true do |t|
    t.integer "enrollment_id"
    t.integer "transaction_id"
  end

  create_table "installments", :force => true do |t|
    t.integer "membership_id"
    t.date    "due_on"
    t.decimal "value",         :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.integer "agent_id"
  end

  create_table "installments_transactions", :force => true do |t|
    t.integer "installment_id"
    t.integer "transaction_id"
  end

  create_table "memberships", :force => true do |t|
    t.integer "business_id"
    t.integer "contact_id"
    t.date    "begins_on"
    t.date    "ends_on"
    t.decimal "value",       :precision => 8, :scale => 2, :default => 0.0, :null => false
  end

  create_table "products", :force => true do |t|
    t.string  "name",                                      :default => "Unknown", :null => false
    t.decimal "price",       :precision => 8, :scale => 2, :default => 0.0,       :null => false
    t.string  "currency"
    t.integer "business_id"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "sales", :force => true do |t|
    t.integer "business_id"
    t.integer "contact_id"
    t.integer "agent_id"
    t.integer "product_id"
  end

  create_table "sales_transactions", :force => true do |t|
    t.integer "sale_id"
    t.integer "transaction_id"
  end

  create_table "taggings", :force => true do |t|
    t.integer "transaction_id"
    t.integer "tag_id"
  end

  create_table "tags", :force => true do |t|
    t.string  "name",        :default => "", :null => false
    t.integer "business_id"
  end

  create_table "transactions", :force => true do |t|
    t.string   "type",                                                           :null => false
    t.string   "description",                                   :default => "",  :null => false
    t.integer  "business_id"
    t.integer  "source_id",                                                      :null => false
    t.decimal  "amount",          :precision => 8, :scale => 2,                  :null => false
    t.datetime "transaction_at"
    t.integer  "creator_id"
    t.integer  "target_id"
    t.decimal  "conversion_rate", :precision => 8, :scale => 2, :default => 1.0, :null => false
    t.string   "state"
    t.datetime "reconciled_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
