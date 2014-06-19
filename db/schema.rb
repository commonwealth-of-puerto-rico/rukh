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

ActiveRecord::Schema.define(version: 20140619193723) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

  create_table "debtors", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "tel"
    t.string   "ext"
    t.string   "address"
    t.string   "location"
    t.string   "contact_person"
    t.string   "contact_person_email"
    t.string   "employer_id_number"
    t.string   "ss_hex_digest"
    t.string   "ss_last_four"
    t.boolean  "uses_personal_ss"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "debtors", ["employer_id_number"], name: "index_debtors_on_employer_id_number"
  add_index "debtors", ["name"], name: "index_debtors_on_name", unique: true
  add_index "debtors", ["ss_hex_digest"], name: "index_debtors_on_ss_hex_digest", unique: true

  create_table "debts", force: true do |t|
    t.string   "permit_infraction_number"
    t.decimal  "amount_owed_pending_balance",     precision: 12, scale: 2
    t.boolean  "paid_in_full",                                             default: false
    t.string   "type_of_debt"
    t.date     "original_debt_date",                                                       null: false
    t.decimal  "originating_debt_amount",         precision: 12, scale: 2
    t.integer  "bank_routing_number"
    t.string   "bank_name"
    t.integer  "bounced_check_number"
    t.boolean  "in_payment_plan",                                          default: false
    t.boolean  "in_administrative_process",                                default: false
    t.string   "contact_person_for_transactions"
    t.string   "notes"
    t.integer  "debtor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mail_logs", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "debt_id"
    t.integer  "mailer_id"
    t.string   "mailer_name"
    t.datetime "datetime_sent"
    t.string   "email_sent_to"
    t.text     "mailer_content"
    t.string   "mailer_subject"
  end

  create_table "user_roles", force: true do |t|
    t.string   "role_name",  default: "normal_user"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "developer",  default: false
    t.integer  "user_id"
  end

  add_index "user_roles", ["role_name"], name: "index_user_roles_on_role_name", unique: true

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_role_id",           default: 1
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
