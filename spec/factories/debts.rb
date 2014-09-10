# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :debt do
    association :debtor
    sequence(:id) {|n| n}
    permit_infraction_number { "M-12-12-#{rand(100..999)}-RC" }
    amount_owed_pending_balance {rand(12).to_s}
    paid_in_full :false
    type_of_debt 'multa'
    original_debt_date { "#{rand(1980..2014)}-#{rand(1..12)}-#{rand(1..28)}" }
    originating_debt_amount { rand(12).to_s }
    bank_routing_number {rand(111111111..999999999)}
    sequence(:bank_name) {|n| "FactoryGirlBank#{n}"}
    bounced_check_number {rand 1..11}
    in_payment_plan :false
    in_administrative_process :false
    contact_person_for_transactions "Guicho"
    notes "That will do gem, that will do."
    created_at {Date.yesterday} #DateTime.now.yesterday
    updated_at {Date.today}
    fimas_project_id ''
    fimas_class_field ''
    fimas_budget_reference ''
    fimas_program ''
    fimas_fund_code ''
    fimas_account ''
    fimas_id ''
  end
end


=begin
  create_table "debts", force: true do |t|     sequence(:debt_id) {|n| n}
    t.string   "permit_infraction_number" ### SEQUENCE { Date.parse("#{rand(1..12)}-#{rand(1..28)}-#{rand(1980..2014)}") }
    t.decimal  "amount_owed_pending_balance",   ### SEQUENCE              precision: 12, scale: 2
    t.boolean  "paid_in_full",                                             default: false
    t.string   "type_of_debt"
    t.date     "original_debt_date",                                                       null: false
    t.decimal  "originating_debt_amount",         precision: 12, scale: 2
    t.integer  "bank_routing_number" ### SEQUENCE 9 digit
    t.string   "bank_name"
    t.integer  "bounced_check_number" ### SEQUENCE
    t.boolean  "in_payment_plan",                                          default: false
    t.boolean  "in_administrative_process",                                default: false
    t.string   "contact_person_for_transactions"
    t.string   "notes"
    t.integer  "debtor_id"     debtor_id {rand(1..99)} replaced w/ association
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fimas_project_id" ### SEQUENCE?
    t.string   "fimas_budget_reference"
    t.string   "fimas_class_field"
    t.string   "fimas_program"
    t.string   "fimas_fund_code"
    t.string   "fimas_account"
    t.string   "fimas_id" ### SEQUENCE?
  end
=end