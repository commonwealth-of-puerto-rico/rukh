class AddMailSubjectToMailLogs < ActiveRecord::Migration
  def change
    add_column :mail_logs, :mailer_subject, :string
  end
end
