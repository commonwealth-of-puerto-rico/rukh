class DropEmailSentToRecreateWithoutLimit < ActiveRecord::Migration
  def change
    remove_column :mail_logs, :email_sent_to, :text
    add_column :mail_logs, :email_sent_to, :text
  end
end
