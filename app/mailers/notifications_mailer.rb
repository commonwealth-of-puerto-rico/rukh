class NotificationsMailer < ActionMailer::Base
  # default from: "from@example.com"
  # after_action :update_debt 
  # after_action :log_mail # Does after send exist?
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications_mailer.first.subject
  #
  def first(debt, user)
    # Guards:
    fail if user.nil? # user is definded
    fail if debt.nil? # but not debt.
    
    @debt = debt 
    @user = user 
    
    mail(from: @user.email,
         to:   @debt.debtor.email, 
         cc:   @debt.debtor.contact_person_email, 
         bcc:  @user.email, 
         subject: "Primera Notificación") do |format|
      format.html
    end
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications_mailer.second.subject
  #
  def second(debt, user)
    # Guards:
    fail if user.nil? # user is definded
    fail if debt.nil? # but not debt.
    
    @debt = debt 
    @user = user 

    mail(from: @user.email,
         to:   @debt.debtor.email, 
         cc:   @debt.debtor.contact_person_email, 
         bcc:  @user.email, 
         subject: "Segunda Notificación") do |format|
      format.html
    end
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications_mailer.third.subject
  #
  def third(debt, user)
    # Guards:
    fail if user.nil? # user is definded
    fail if debt.nil? # but not debt.
    
    @debt = debt 
    @user = user 

    mail(from: @user.email,
         to:   @debt.debtor.email, 
         cc:   @debt.debtor.contact_person_email, 
         bcc:  @user.email,
         subject: "Tercera Notificación") do |format|
      format.html
    end
  end
  
  private
    def add_logo! 
      attachments.inline['logo.png'] = File.read("#{Rails.root}public/assets/images/email_logo.png")
    end
end

=begin
  # before_action :authenticate_user! ## for DEVISE #TODO Figure out how to call :authenticate_user from here
  # default from: 
  # before_action :add_inline_logo! #use only for notifications
=end