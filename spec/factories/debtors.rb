# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :debtor do
    name "Hombre Bionico"
    email "carlostrabal@example.com"
    tel "787-761-6767"
    ext "x5555"
    address "Happy Drive PO box"
    location "Km 4 Carr. 123"
    contact_person "Carlos Trabal"
    contact_person_email "ct@example.com"
    uses_personal_ss true
    ss_hex_digest "123456789"
  end
end

=begin
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
=end