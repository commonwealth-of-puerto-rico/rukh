# -*- encoding : utf-8 -*-
class ChangeMailLogsFieldsToLargerText < ActiveRecord::Migration
  def change
    # remove_column :mail_logs, :mailer_id, :integer
    # add_column :mail_logs, :mailer_id, :string
    # remove_column :mail_logs, :email_sent_to, :string
    # add_column :mail_logs, :email_sent_to, :text
    change_column :mail_logs, :mailer_id, :string
    change_column :mail_logs, :email_sent_to, :text
  end
end


