# -*- encoding : utf-8 -*-
class RenameColumnInMailLog < ActiveRecord::Migration
  def change
    rename_column :mail_logs, :sent_to_email, :email_sent_to
  end
end
