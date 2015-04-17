# -*- encoding : utf-8 -*-
class AddFimasFieldsToDebts < ActiveRecord::Migration
  def change
    add_column :debts, :fimas_project_id, :string
    add_column :debts, :fimas_budget_reference, :string
    add_column :debts, :fimas_class_field, :string
    add_column :debts, :fimas_program, :string
    add_column :debts, :fimas_fund_code, :string
    add_column :debts, :fimas_account, :string
  end
end

# add_column :users, :user_role_id, :integer, default: 1
