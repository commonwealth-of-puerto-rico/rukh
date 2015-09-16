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

ActiveRecord::Schema.define(version: 20140722145656) do

  create_table "debtors", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "email",                limit: 255
    t.string   "tel",                  limit: 255
    t.string   "ext",                  limit: 255
    t.string   "address",              limit: 255
    t.string   "location",             limit: 255
    t.string   "contact_person",       limit: 255
    t.string   "contact_person_email", limit: 255
    t.string   "employer_id_number",   limit: 255
    t.string   "ss_hex_digest",        limit: 255
    t.string   "ss_last_four",         limit: 255
    t.boolean  "uses_personal_ss"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "debtors", ["employer_id_number"], name: "index_debtors_on_employer_id_number"
  add_index "debtors", ["name"], name: "index_debtors_on_name", unique: true
  add_index "debtors", ["ss_hex_digest"], name: "index_debtors_on_ss_hex_digest", unique: true

  create_table "debts", force: :cascade do |t|
    t.string   "permit_infraction_number",        limit: 255
    t.decimal  "amount_owed_pending_balance",                 precision: 12, scale: 2
    t.boolean  "paid_in_full",                                                         default: false
    t.string   "type_of_debt",                    limit: 255
    t.date     "original_debt_date",                                                                   null: false
    t.decimal  "originating_debt_amount",                     precision: 12, scale: 2
    t.integer  "bank_routing_number"
    t.string   "bank_name",                       limit: 255
    t.integer  "bounced_check_number"
    t.boolean  "in_payment_plan",                                                      default: false
    t.boolean  "in_administrative_process",                                            default: false
    t.string   "contact_person_for_transactions", limit: 255
    t.string   "notes",                           limit: 255
    t.integer  "debtor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fimas_project_id",                limit: 255
    t.string   "fimas_budget_reference",          limit: 255
    t.string   "fimas_class_field",               limit: 255
    t.string   "fimas_program",                   limit: 255
    t.string   "fimas_fund_code",                 limit: 255
    t.string   "fimas_account",                   limit: 255
    t.string   "fimas_id",                        limit: 255
  end

  create_table "fimas_accounts", force: :cascade do |t|
    t.string   "description", limit: 255
    t.string   "code",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mail_logs", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "debt_id"
    t.string   "mailer_id",      limit: 255
    t.string   "mailer_name",    limit: 255
    t.datetime "datetime_sent"
    t.text     "mailer_content"
    t.string   "mailer_subject", limit: 255
    t.text     "email_sent_to"
  end

  create_table "user_roles", force: :cascade do |t|
    t.string   "role_name",  limit: 255, default: "normal_user"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "developer",              default: false
    t.integer  "user_id"
  end

  add_index "user_roles", ["role_name"], name: "index_user_roles_on_role_name", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_role_id",                       default: 1
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
