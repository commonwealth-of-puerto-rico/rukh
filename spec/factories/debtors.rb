# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :debtor do
    name { Faker::Name.name }
    email { Faker::Internet.safe_email }
    tel "787-761-6767"
    ext "x#{Faker::PhoneNumber.extension}"
    address { "#{Faker::Address.street_address}, #{Faker::Address.city}, #{Faker::Address.zip}" }
    location { "#{Faker::Address.street_name}, #{Faker::Address.secondary_address}" }
    contact_person { Faker::Name.name }
    contact_person_email { Faker::Internet.safe_email }
    uses_personal_ss false
    ss_hex_digest ''
    employer_id_number { Faker::Company.ein }
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
