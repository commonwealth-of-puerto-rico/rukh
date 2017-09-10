module MailSupport
  ## Mail Methods ## (Should be in elsewhere, move to /lib)
  #
  def prepare_email(debt, user, mailer, options = {})
    date_first_email_sent = options.fetch :date_first_email_sent, 'fecha de primer aviso no encontrada'
    display_attachments   = options.fetch :display_attachments,   true

    if guard_mailer(mailer)
      @mail_preview = NotificationsMailer.public_send(mailer, debt, user,
                                                      date_first_email_sent: date_first_email_sent,
                                                      display_attachments: display_attachments)
      if options.fetch :send, false
        deliver_mail(debt, user, mailer, @mail_preview)
      end
      # refactor? options.fetch(:send, false) and deliver_mail(debt, user, mailer, @mail_preview)
    else
      flash[:error] = 'Email No Encontrado'
    end
  end

  def deliver_mail(debt, user, mailer, mail_preview, _options = {})
    require 'thread'
    # TODO: replace w/ actor?
    Thread.new do
      begin
        if mail_preview.deliver # guard_mailer(mailer) &&
          # Log Mail
          log_email(mail_preview, debt, user, mailer_name: mailer)
          flash[:success] = "Email: #{mail_preview.subject} Enviado"
        else
          flash[:error] = 'Email No Enviado'
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
    end.join
  end

  def guard_mailer(mailer)
    %i[first second third].include?(mailer) && NotificationsMailer.respond_to?(mailer)
  end

  def date_first_email_sent(debt)
    date_first_email_sent_raw = debt.mail_logs.find_by_mailer_name(:first)
    if date_first_email_sent_raw
      I18n.l date_first_email_sent_raw.datetime_sent.to_date, format: '%d de %B de %Y'
    else
      'fecha de primer aviso no encontrada'
    end
  end

  ## Helper methods ##
  # TODO Put Method Below in helper
  def strip_hyphens(string)
    string.to_s.split('').reject { |x| x.match(/-/) }.join('')
  end

  # rubocop:disable Metrics/AbcSize
  def log_email(mail, debt, user, options = {})
    require 'base64' # To encode content to prevent SQL injections
    mail_log = MailLog.create(
      user_id: user.id,
      debt_id: debt.id,
      mailer_id: mail.message_id,
      mailer_name: options.fetch(:mailer_name, 'unknown').to_s,
      mailer_subject: mail.subject.to_s, # slightly vulnerable to SQL injection
      datetime_sent: DateTime.now,
      email_sent_to: Base64.encode64(mail.header.to_s),
      mailer_content:
        if mail.multipart?
          Base64.encode64(mail.html_part.body.to_s)
        else
          Base64.encode64(mail.body.to_s)
        end
    )
    mail_log.save or fail('Unable to log email.')
  end
end
