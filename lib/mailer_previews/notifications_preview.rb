# -*- encoding : utf-8 -*-
class NotificationsPreview < ActionMailer::Preview
  #The name of the methods here determines the name of the preview,
  # but the mail object they returns determines what gets rendered.
  
  def first_notification
    Notifications.first_notification(Debtor.first)
  end
  def welcome
    Notifications.second_notification(Debtor.first)
  end
end

# Note: It is very important that this file be named in Underscores. Otherwise ActionMailer will miss it
# Configuration is in config/environments/development.rb (because previews tend to only be used in development.)
#TODO see if it will work in production

#TODO is this file needed??
