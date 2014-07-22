class DebtsController < ApplicationController
  before_action :authenticate_user! ## for DEVISE
  
  ## Resource Actions
  def new
    assign_current_user
    @debtor = Debtor.find_by_id(params[:debtor_id])#something w/ params
    @debt = Debt.new
  end
  
  def edit
    assign_current_user
    @debt = Debt.find_by_id(params[:id]) #something w/ params
    @debtor = Debtor.find_by_id(@debt.debtor_id)
  end
  
  def show
    assign_current_user
    @debt = Debt.find_by_id(params[:id])
    @debtor = Debtor.find_by_id @debt.debtor_id
  end
  
  def index
    assign_current_user
    case params['format']
    when 'csv', 'xls'
      @debts_all = Debt.all()
    else
      @debts_all = Debt.paginate(page: params[:page], per_page: 10)
    end   
    respond_to do |format|
      format.html
      format.csv { send_data @debts_all.to_csv}
      format.xls 
    end
  end
  
  def create
    assign_current_user
    @debtor = Debtor.find_by_id(params[:debtor_id])
    fail if @debtor.nil?
    params[:debt][:debtor_id] = @debtor.id
    @debt = Debt.new(debt_params)
    @debt.permit_infraction_number = strip_hyphens(@debt.permit_infraction_number)
    @debt.originating_debt_amount = @debt.amount_owed_pending_balance
    if @debt.save
      flash[:success] = "Nueva Factura Creada"
      redirect_to @debt
    else
      flash[:error] = "Factura No Gravada"
      render 'new'
    end
  end
  
  def update
    assign_current_user
    @debt = Debt.find_by_id(params[:id]) #something w/ params
    @debtor = Debtor.find_by_id(@debt.debtor_id)
    @debt.permit_infraction_number = strip_hyphens(@debt.permit_infraction_number)
    if @debt.update_attributes(update_debt_params) && @debt.valid?
      flash[:success] = "Factura Actualizada"
      redirect_to @debt
    else
      flash[:error] = "Factura No Actualizada"
      render 'edit'
    end  
  end
  
  def preview_email   
    @debt = Debt.find_by_id(mailer_params[:id])
    @user = current_user
    @mailer = mailer_params[:mailer].to_sym
    @date_first_email_sent = date_first_email_sent(@debt)
    @print = (mailer_params[:print] == 'true') ? true : false
    prepare_email(@debt, @user, @mailer, preview: true, 
      date_first_email_sent: @date_first_email_sent, 
      display_attachments: false)

    render layout: false 
  end
  
  def send_email #should be Post only
    @debt = Debt.find_by_id(mailer_params[:id])
    @user = current_user
    @mailer = mailer_params[:mailer].to_sym
    @date_first_email_sent = date_first_email_sent(@debt)
    prepare_email(@debt, @user, @mailer, send: true,
      date_first_email_sent: @date_first_email_sent, 
      display_attachments: true)
    
    redirect_to @debt
  end
  
  private
  ## Mail Methods (Should be in elsewhere)
  def prepare_email(debt, user, mailer, options={})  
    date_first_email_sent = options.fetch :date_first_email_sent, "fecha de primer aviso no encontrada"
    display_attachments = options.fetch :display_attachments, true
    
    if guard_mailer(mailer) 
      @mail_preview = NotificationsMailer.public_send(mailer, debt, user, 
        date_first_email_sent: date_first_email_sent, display_attachments: display_attachments)
      if options.fetch :send, false 
        deliver_mail(debt, user, mailer, @mail_preview)
      end
    else 
      flash[:error] = "Email No Encontrado"
    end
  end
  
  def deliver_mail(debt, user, mailer, mail_preview, options={})
    require 'thread' 
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
      # rescue ActiveRecord::JDBCError => e
      #   flash[:error] = "Log no creado ActiveRecord::JDBCError #{e}"
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
  
  ## Controller Private Methods
  def assign_current_user
    @user = current_user
  end
  
  def mailer_params
    if user_signed_in? #Devise
      #If only used for sending can validate user role
      params.permit(
      :mailer,
      :id,
      :print)
    else
      flash[:error] = "Usuario No autorizado."
      redirect_to :back
    end
  end
  
  def debt_params
    if user_signed_in? #updated for Devise
      #Can be determined by role
      params.require(:debt).permit(
        :permit_infraction_number,
        :amount_owed_pending_balance,
        :paid_in_full,
        :type_of_debt,
        :original_debt_date,
        :originating_debt_amount,
        :bank_routing_number,
        :bank_name,
        :bounced_check_number,
        :in_payment_plan,
        :in_administrative_process,
        :contact_person_for_transactions,
        :notes,
        :debtor_id,
        :fimas_project_id,
        :fimas_budget_reference,
        :fimas_class_field,
        :fimas_program,
        :fimas_fund_code,
        :fimas_account)
    else
      redirect_to new_user_session_path
    end
  end
  
  def update_debt_params
    if user_signed_in? #updated for Devise
      #Can be determined by role
      params.require(:debt).permit(
        :permit_infraction_number,
        :amount_owed_pending_balance,
        :paid_in_full,
        :type_of_debt,
        :bank_routing_number,
        :bank_name,
        :bounced_check_number,
        :in_payment_plan,
        :in_administrative_process,
        :contact_person_for_transactions,
        :notes)
    else
      redirect_to new_user_session_path
    end
  end
  
  #TODO Put Method Below in helper
  def strip_hyphens(string)
    string.to_s.split('').reject{|x| x.match(/-/)}.join('')
  end
  
  #TODO Method Below could be In Lib
  def log_email(mail, debt, user, options={})
    require 'base64'
    mail_log = MailLog.create(
      user_id: user.id,
      debt_id: debt.id,
      mailer_id: mail.message_id,
      mailer_name: options.fetch(:mailer_name, 'unknown').to_s, 
      mailer_subject: mail.subject.to_s, 
      datetime_sent: DateTime.now,
      email_sent_to: Base64.encode64(mail.header.to_s),
      mailer_content: mail.multipart? ? Base64.encode64(mail.html_part.body.to_s) : Base64.encode64(mail.body.to_s)
    )
    mail_log.save or fail 
  end
  
end

__END__

