#TODO move mail methods here from debts controller

require 'thread'


module MailSupportMethods
  #
  def prepare_email(debt, user, mailer, options={})  
    date_first_email_sent = options.fetch :date_first_email_sent, "fecha de primer aviso no encontrada"
    display_attachments   = options.fetch :display_attachments,   true
    
    if guard_mailer(mailer) 
      @mail_preview = NotificationsMailer.public_send(mailer, debt, user, 
        date_first_email_sent: date_first_email_sent, display_attachments: display_attachments)
      if options.fetch :send, false 
        deliver_mail(debt, user, mailer, @mail_preview)
      end
      # refactor? options.fetch(:send, false) and deliver_mail(debt, user, mailer, @mail_preview)
    else 
      flash[:error] = "Email No Encontrado"
    end
  end
  
  def deliver_mail(debt, user, mailer, mail_preview, _options={})
    require 'thread' 
    #TODO replace w/ actor?
    Thread.new {
      begin 
        if mail_preview.deliver #guard_mailer(mailer) &&
          # Log Mail
          log_email(mail_preview, debt, user, mailer_name: mailer)
          flash[:success] = "Email: #{mail_preview.subject} Enviado"
        else
          flash[:error] = "Email No Enviado"
        end
      rescue SocketError => e
        flash[:error] = "Conexión al servidor de emails falló: SocketError:#{e}"
      rescue Errno::ECONNREFUSED => e
        flash[:error] = "Conexión al servidor de emails falló: Errno::ECONNREFUSED:#{e}"
      rescue Net::SMTPFatalError => e
        flash[:error] = "Error del server SMTP: Net::SMTPFatalError #{e}"
      rescue ActiveRecord::JDBCError => e
        flash[:error] = "Log no creado ActiveRecord::JDBCError #{e}"
      end 
    }.join() 
  end
  
  def guard_mailer(mailer)
    [:first,:second,:third].include?(mailer) && NotificationsMailer.respond_to?(mailer)
  end
  
  def date_first_email_sent(debt)
    date_first_email_sent_raw = debt.mail_logs.find_by_mailer_name(:first)
    if date_first_email_sent_raw
      I18n.l (date_first_email_sent_raw.datetime_sent.to_date), :format => '%d de %B de %Y'
    else
      "fecha de primer aviso no encontrada"
    end
  end
  
end

