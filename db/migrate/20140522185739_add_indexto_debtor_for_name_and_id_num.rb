# -*- encoding : utf-8 -*-
class AddIndextoDebtorForNameAndIdNum < ActiveRecord::Migration
  def change
    add_index :debtors, :employer_id_number
    add_index :debtors, :name,          unique: true
    add_index :debtors, :ss_hex_digest, unique: true
    
  end
end
