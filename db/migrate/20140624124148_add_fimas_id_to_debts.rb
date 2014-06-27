class AddFimasIdToDebts < ActiveRecord::Migration
  def change
    add_column :debts, :fimas_id, :string
  end
end
