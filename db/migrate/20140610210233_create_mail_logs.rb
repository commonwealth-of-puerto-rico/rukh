class CreateMailLogs < ActiveRecord::Migration
  def change
    create_table :mail_logs do |t|

      t.timestamps
    end
  end
end
