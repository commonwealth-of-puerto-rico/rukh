class AddRowsToMailLogs < ActiveRecord::Migration
  def change
    change_table :mail_logs do |t|
      t.integer :user_id
      t.integer :debt_id
      t.integer :mailer_id
      t.string :mailer_name
      t.datetime :datetime_sent
      t.string :sent_to_email
      t.text :mailer_content 
    end
  end
end
