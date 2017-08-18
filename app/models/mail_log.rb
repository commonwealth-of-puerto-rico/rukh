# -*- encoding : utf-8 -*-

class MailLog < ActiveRecord::Base
  belongs_to :debt
  # before_destroy false #Is this Rails 4 compatible?
end

=begin
##
t.integer :user_id
t.integer :debt_id
t.integer :mailer_id
t.string :mailer_name
t.datetime :datetime_sent
t.string :sent_to_email
t.text :mailer_content
=end
