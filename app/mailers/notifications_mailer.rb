# -*- encoding : utf-8 -*-
class NotificationsMailer < ActionMailer::Base
  # default from: "from@example.com"
  # after_action :update_debt 
  # after_action :log_mail # Does after send exist?
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications_mailer.first.subject
  #
  def first(debt, user, options={})
    # Guards:
    fail if user.nil? # user is definded
    fail if debt.nil? # but not debt.
    
    @debt = debt 
    @user = user 
    add_return_receipt headers, @user.email
    @display_attachments = options[:display_attachments]
    add_signature!
    
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
  def second(debt, user, options={})
    # Guards:
    fail if user.nil? # user is definded
    fail if debt.nil? # but not debt.
    
    @debt = debt 
    @user = user 
    add_return_receipt headers, @user.email
    
    @date_first_email_sent = options[:date_first_email_sent]
    @display_attachments = options[:display_attachments]
    add_signature!

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
  def third(debt, user, options={})
    # Guards:
    fail if user.nil? # user is definded
    fail if debt.nil? # but not debt.
    
    @debt = debt 
    @user = user
    add_return_receipt headers, @user.email
    
    @date_first_email_sent = options[:date_first_email_sent]
    @display_attachments = options[:display_attachments]
    add_signature!

    mail(from: @user.email,
         to:   @debt.debtor.email, 
         cc:   @debt.debtor.contact_person_email, 
         bcc:  @user.email,
         subject: "Tercera Notificación") do |format|
      format.html
    end
  end
  
  private
    def add_return_receipt(headers, email)
      headers[:'Return-Receipt-To'] = email
      headers[:'Disposition-Notification'] = email
      headers[:'X-Confirm-Reading-To'] = email 
    end
  
    def add_logo! 
      attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/57.png")
    end
    def add_signature!
      attachments.inline['signature.jpg'] = File.read("#{Rails.root}/app/assets/images/signature.jpg")
    end
end

=begin
  # before_action :authenticate_user! ## for DEVISE #TODO Figure out how to call :authenticate_user from here
  # default from: 
  # before_action :add_inline_logo! #use only for notifications
=end
