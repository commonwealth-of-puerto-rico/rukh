class CreateDebtors < ActiveRecord::Migration
  def change
    create_table :debtors do |t|
      t.string   :name
      t.string   :email
      t.string   :tel
      t.string   :ext
      t.string   :address
      t.string   :location
      t.string   :contact_person
      t.string   :contact_person_email
      t.string   :employer_id_number
      t.string   :ss_hex_digest
      t.string   :ss_last_four
      t.boolean  :uses_personal_ss
      
      t.timestamps
    end
  end
end
