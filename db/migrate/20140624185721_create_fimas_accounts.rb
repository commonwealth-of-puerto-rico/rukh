# -*- encoding : utf-8 -*-
class CreateFimasAccounts < ActiveRecord::Migration
  def change
    create_table :fimas_accounts do |t|
      t.string :description
      t.string :code

      t.timestamps
    end
  end
end
