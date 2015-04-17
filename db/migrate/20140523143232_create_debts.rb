# -*- encoding : utf-8 -*-
class CreateDebts < ActiveRecord::Migration
  def change
    create_table :debts do |t|
      t.string    :permit_infraction_number
      t.decimal   :amount_owed_pending_balance,     precision: 12, scale: 2 
      t.boolean   :paid_in_full,                    default: false
      t.string    :type_of_debt
      t.date      :original_debt_date
      t.decimal   :originating_debt_amount,         precision: 12, scale: 2 
      t.integer   :bank_routing_number
      t.string    :bank_name
      t.integer   :bounced_check_number
      t.boolean   :in_payment_plan,                  default: false
      t.boolean   :in_administrative_process,        default: false
      t.string    :contact_person_for_transactions
      t.string    :notes
      
      t.integer   :debtor_id
      # t.integer   :payment_plan_id
      # t.string    :contac_person_id_number
      

      t.timestamps
    end
  end
end
