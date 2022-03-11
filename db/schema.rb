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

ActiveRecord::Schema.define(version: 20220311193152) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "name",          limit: 255,                          default: "",  null: false
    t.integer  "business_id"
    t.decimal  "old_balance",               precision: 12, scale: 2, default: 0.0
    t.string   "currency",      limit: 255
    t.datetime "deleted_at"
    t.boolean  "default"
    t.integer  "balance_cents"
  end

  add_index "accounts", ["deleted_at"], name: "index_accounts_on_deleted_at", using: :btree

  create_table "admparts", force: :cascade do |t|
    t.integer  "business_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "director_from_profit_percentage"
    t.integer  "owners_percentage"
    t.integer  "dir_from_owners_aft_expses_percentage"
    t.integer  "agent_sale_percentage"
    t.integer  "agent_enrollment_income_percentage"
    t.integer  "agent_enrollment_quantity_fixed_amount"
    t.integer  "agent_installments_attendance_percentage"
    t.date     "ref_date"
  end

  add_index "admparts", ["business_id"], name: "index_admparts_on_business_id", using: :btree

  create_table "agents", force: :cascade do |t|
    t.string  "name",        limit: 255, default: "Unknown", null: false
    t.integer "business_id"
    t.string  "padma_id",    limit: 255
    t.boolean "disabled",                default: false
  end

  create_table "balance_checks", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "creator_id"
    t.integer  "balance_cents"
    t.datetime "checked_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "difference_transaction_id"
  end

  add_index "balance_checks", ["account_id"], name: "index_balance_checks_on_account_id", using: :btree

  create_table "businesses", force: :cascade do |t|
    t.string   "name",                      limit: 255, default: "",         null: false
    t.integer  "owner_id",                                                   null: false
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "type",                      limit: 255, default: "Personal"
    t.string   "padma_id",                  limit: 255
    t.datetime "synchronized_at"
    t.boolean  "send_weekly_reports",                   default: true
    t.boolean  "transactions_enabled"
    t.boolean  "share_enabled"
    t.boolean  "use_calendar_installments",             default: true
    t.integer  "derose_events_id"
    t.string   "currency_code",             limit: 255
    t.datetime "block_transactions_before"
  end

  create_table "businesses_users", force: :cascade do |t|
    t.integer "business_id"
    t.integer "user_id"
    t.boolean "show_on_menu", default: true
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name",                  limit: 255, default: "Unknown", null: false
    t.integer  "business_id"
    t.string   "padma_id",              limit: 255
    t.string   "padma_status",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "padma_teacher",         limit: 255
    t.integer  "current_membership_id"
  end

  add_index "contacts", ["business_id", "padma_id"], name: "index_contacts_on_business_id_and_padma_id", using: :btree
  add_index "contacts", ["current_membership_id"], name: "index_contacts_on_current_membership_id", using: :btree

  create_table "custom_prizes", force: :cascade do |t|
    t.integer  "admpart_id"
    t.integer  "agent_id"
    t.decimal  "amount"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "admpart_section", limit: 255
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "enrollments", force: :cascade do |t|
    t.integer "membership_id"
    t.decimal "value",         precision: 8, scale: 2, default: 0.0, null: false
    t.integer "agent_id"
    t.date    "enrolled_on"
  end

  add_index "enrollments", ["agent_id"], name: "index_enrollments_on_agent_id", using: :btree
  add_index "enrollments", ["membership_id"], name: "index_enrollments_on_membership_id", using: :btree

  create_table "enrollments_transactions", force: :cascade do |t|
    t.integer "enrollment_id"
    t.integer "transaction_id"
  end

  add_index "enrollments_transactions", ["enrollment_id", "transaction_id"], name: "enrollments_transactions_link_index", using: :btree

  create_table "imports", force: :cascade do |t|
    t.integer  "business_id"
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.text     "errors_csv"
    t.string   "status",              limit: 255
    t.string   "type",                limit: 255
    t.integer  "account_id"
    t.string   "description",         limit: 255
    t.boolean  "archived"
  end

  create_table "imports_transactions", force: :cascade do |t|
    t.integer "import_id"
    t.integer "transaction_id"
  end

  create_table "inscriptions", force: :cascade do |t|
    t.integer  "business_id"
    t.integer  "contact_id"
    t.decimal  "value",                       precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "balance",                     precision: 8, scale: 2, default: 0.0, null: false
    t.integer  "payment_type_id"
    t.integer  "external_id"
    t.string   "observations",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "padma_account",   limit: 255
  end

  create_table "inscriptions_transactions", force: :cascade do |t|
    t.integer "inscription_id"
    t.integer "transaction_id"
  end

  create_table "installment_imports_installments", force: :cascade do |t|
    t.integer "installment_import_id"
    t.integer "installment_id"
  end

  create_table "installments", force: :cascade do |t|
    t.integer  "membership_id"
    t.date     "due_on"
    t.decimal  "old_value",                 precision: 8, scale: 2, default: 0.0
    t.integer  "agent_id"
    t.decimal  "old_balance",               precision: 8, scale: 2, default: 0.0
    t.integer  "external_id"
    t.string   "observations",  limit: 255
    t.string   "status",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "value_cents",                                       default: 0
    t.integer  "balance_cents",                                     default: 0
  end

  add_index "installments", ["agent_id"], name: "index_installments_on_agent_id", using: :btree
  add_index "installments", ["membership_id", "updated_at"], name: "index_installments_on_membership_id_and_updated_at", using: :btree
  add_index "installments", ["membership_id"], name: "index_installments_on_membership_id", using: :btree

  create_table "installments_transactions", force: :cascade do |t|
    t.integer "installment_id"
    t.integer "transaction_id"
  end

  add_index "installments_transactions", ["installment_id", "transaction_id"], name: "installment_transaction_link_index", using: :btree

  create_table "membership_imports_memberships", force: :cascade do |t|
    t.integer "membership_import_id"
    t.integer "membership_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "business_id"
    t.integer  "contact_id"
    t.date     "begins_on"
    t.date     "ends_on"
    t.decimal  "old_value",                   precision: 8, scale: 2, default: 0.0
    t.date     "closed_on"
    t.integer  "payment_type_id"
    t.boolean  "vip"
    t.string   "external_id"
    t.integer  "monthly_due_day"
    t.string   "name",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "value_cents"
  end

  add_index "memberships", ["business_id", "payment_type_id"], name: "index_memberships_on_business_id_and_payment_type_id", using: :btree
  add_index "memberships", ["business_id"], name: "index_memberships_on_business_id", using: :btree
  add_index "memberships", ["contact_id"], name: "index_memberships_on_contact_id", using: :btree
  add_index "memberships", ["payment_type_id"], name: "index_memberships_on_payment_type_id", using: :btree

  create_table "month_tag_totals", force: :cascade do |t|
    t.integer  "tag_id"
    t.date     "ref_date"
    t.decimal  "old_total_amount"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "currency",           limit: 255
    t.integer  "total_amount_cents"
  end

  create_table "payment_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description"
    t.integer  "business_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "product_imports_products", force: :cascade do |t|
    t.integer "product_import_id"
    t.integer "product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string  "name",           limit: 255,                         default: "Unknown", null: false
    t.decimal "price",                      precision: 8, scale: 2, default: 0.0,       null: false
    t.string  "price_currency", limit: 255
    t.integer "business_id"
    t.decimal "cost",                       precision: 8, scale: 2, default: 0.0,       null: false
    t.string  "cost_currency",  limit: 255
    t.integer "stock",                                              default: 0
    t.boolean "hidden",                                             default: false
    t.integer "external_id"
  end

  create_table "recurrent_transactions", force: :cascade do |t|
    t.integer  "business_id"
    t.integer  "source_id"
    t.integer  "target_id"
    t.string   "description"
    t.string   "type"
    t.decimal  "old_amount"
    t.integer  "contact_id"
    t.integer  "agent_id"
    t.integer  "admpart_tag_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "state"
    t.integer  "amount_cents"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id"
    t.string   "resource_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sale_imports_sales", force: :cascade do |t|
    t.integer "sale_import_id"
    t.integer "sale_id"
  end

  create_table "sales", force: :cascade do |t|
    t.integer "business_id"
    t.integer "contact_id"
    t.integer "agent_id"
    t.integer "product_id"
    t.date    "sold_on"
    t.integer "external_id"
  end

  create_table "sales_transactions", force: :cascade do |t|
    t.integer "sale_id"
    t.integer "transaction_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "transaction_id"
    t.integer "tag_id"
  end

  add_index "taggings", ["tag_id", "transaction_id"], name: "index_taggings_on_tag_id_and_transaction_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",            limit: 255, default: "", null: false
    t.integer "business_id"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.integer "depth"
    t.integer "children_count"
    t.string  "admpart_section", limit: 255
    t.string  "system_name",     limit: 255
  end

  add_index "tags", ["depth"], name: "index_tags_on_depth", using: :btree
  add_index "tags", ["lft"], name: "index_tags_on_lft", using: :btree
  add_index "tags", ["parent_id"], name: "index_tags_on_parent_id", using: :btree
  add_index "tags", ["rgt"], name: "index_tags_on_rgt", using: :btree

  create_table "transaction_rules", force: :cascade do |t|
    t.string   "operator",       limit: 255
    t.string   "value",          limit: 255
    t.integer  "contact_id"
    t.integer  "agent_id"
    t.integer  "admpart_tag_id"
    t.integer  "business_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.string   "type",                     limit: 255,                                       null: false
    t.string   "description",              limit: 255,                         default: "",  null: false
    t.integer  "business_id"
    t.integer  "source_id",                                                                  null: false
    t.decimal  "old_amount",                           precision: 8, scale: 2
    t.datetime "transaction_at"
    t.integer  "creator_id"
    t.integer  "target_id"
    t.decimal  "conversion_rate",                      precision: 8, scale: 5, default: 1.0, null: false
    t.string   "state",                    limit: 255
    t.datetime "reconciled_at"
    t.date     "report_at"
    t.string   "external_id",              limit: 255
    t.integer  "contact_id"
    t.integer  "agent_id"
    t.integer  "admpart_tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "order_stamp"
    t.integer  "recurrent_transaction_id"
    t.integer  "amount_cents"
  end

  add_index "transactions", ["business_id", "admpart_tag_id", "report_at"], name: "tag_transactions_index", using: :btree
  add_index "transactions", ["business_id", "updated_at"], name: "index_transactions_on_business_id_and_updated_at", using: :btree
  add_index "transactions", ["business_id"], name: "index_transactions_on_business_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",      null: false
    t.string   "encrypted_password",     limit: 255, default: "",      null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.string   "name",                   limit: 255
    t.string   "drc_uid",                limit: 255
    t.string   "overview_mode",          limit: 255, default: "table"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
