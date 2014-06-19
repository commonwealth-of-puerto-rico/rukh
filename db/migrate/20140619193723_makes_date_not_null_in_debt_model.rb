class MakesDateNotNullInDebtModel < ActiveRecord::Migration
  def change
    change_column_null(:debts, :original_debt_date, false )
  end
end
