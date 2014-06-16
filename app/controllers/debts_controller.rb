class DebtsController < ApplicationController
  before_action :authenticate_user! ## for DEVISE
  
  ## Resrouce Actions
  def new
    assign_current_user
    # fail if params[:debtor_id].nil?
    @debtor = Debtor.find_by_id(params[:debtor_id])#something w/ params
    @debt = Debt.new
  end
  def index
    assign_current_user
    @debts_all = Debt.paginate(page: params[:page], per_page: 10)
    # @debts_all = Debt.all()
    
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
    puts @debtor.name
    params[:debt][:debtor_id] = @debtor.id
    # @debt = @debtor.debt.new(debt_params)
    @debt = Debt.new(debt_params)
    if @debt.save
      flash[:success] = "Nueva Factura Creada"
      redirect_to @debt
    else
      flash[:error] = "Factura No Gravada"
      render 'new'
    end
  end
  
  def show
    @debt = Debt.find_by_id(params[:id])
    @debtor = Debtor.find_by_id @debt.debtor_id
  end
  
  def preview_email   
    @debt = Debt.find_by_id(mailer_params[:id])
    @user = current_user
    @mailer = mailer_params[:mailer].to_sym
    @print = (mailer_params[:print] == 'true') ? true : false
    prepare_email(@debt, @user, @mailer, preview: true)
    # # puts "------->#{params.inspect}"
    # @print = mailer_params[:print] == 'true' ? true : false
    # #TODO search MailLogs for first instance of first email sent, date.
    # date_first_email_sent = @debt.mail_logs.find_by_mailer_name("Primera Notificación")
    # @date_first_email_sent = if date_first_email_sent
    #   I18n.l (date_first_email_sent.datetime_sent.to_date), :format => '%d de %B de %Y'
    # else
    #   "fecha de primer aviso no encontrada"
    # end
    # # puts "------->#{@date_first_email_sent.inspect}"
    # #TODO Create logic here to mark which notification to send.
    # if [:first,:second,:third].include?(@mailer) && NotificationsMailer.respond_to?(@mailer)
    #   @preview = NotificationsMailer.public_send(@mailer, @debt, @user, 
    #     date_first_email_sent: @date_first_email_sent, display_attachments: false)
    # else 
    #   flash[:error] = "Email No Encontrado"
    #   redirect_to :back
    # end
    render layout: false #TODO create layout for emails w/ send
  end
  
  def send_email #should be Post only
    @debt = Debt.find_by_id(mailer_params[:id])
    @user = current_user
    @mailer = mailer_params[:mailer].to_sym
    prepare_email(@debt, @user, @mailer, send: true)
    # date_first_email_sent = @debt.mail_logs.find_by_mailer_name("Primera Notificación")
    # @date_first_email_sent = if date_first_email_sent
    #   I18n.l (date_first_email_sent.datetime_sent.to_date), :format => '%d de %B de %Y'
    # else
    #   "fecha de primer aviso no encontrada"
    # end
    # #TODO Create logic here to mark which notification to send.
    # if  [:first,:second,:third].include?(@mailer) && NotificationsMailer.respond_to?(@mailer)
    #   @mail = NotificationsMailer.public_send(@mailer, @debt, @user,
    #     date_first_email_sent: @date_first_email_sent, display_attachments: true)
    #   if @mail.deliver
    #     log_email(@mail, @debt, @user, mailer_name: @mailer)
    #     # LogMail.log_email(@mail, @debt, @user) #TODO refactor to lib
    #     flash[:success] = "Email: #{@mail.subject} Enviado"
    #   else 
    #     flash[:error] = "Email No Enviado"
    #   end
    # else 
    #   flash[:error] = "Email No Encontrado"
    # end
    redirect_to @debt
  end
  
  private
  def prepare_email(debt, user, mailer, options={})  
    date_first_email_sent_raw = debt.mail_logs.find_by_mailer_name("Primera Notificación")
    date_first_email_sent = if date_first_email_sent_raw
      I18n.l (date_first_email_sent_raw.datetime_sent.to_date), :format => '%d de %B de %Y'
    else
      "fecha de primer aviso no encontrada"
    end
    if options.fetch :preview, false
      if guard_mailer(mailer) 
        #[:first,:second,:third].include?(@mailer) && NotificationsMailer.respond_to?(@mailer)
        @preview = NotificationsMailer.public_send(mailer, debt, user, 
          date_first_email_sent: date_first_email_sent, display_attachments: false)
      else 
        flash[:error] = "Email No Encontrado"
        redirect_to :back
      end
    elsif options.fetch :send, false
      if  guard_mailer(@mailer)
        @mail = NotificationsMailer.public_send(mailer, debt, user,
          date_first_email_sent: date_first_email_sent, display_attachments: true)
        if @mail.deliver
          #Log Mail
          log_email(@mail, debt, user, mailer_name: mailer)
          flash[:success] = "Email: #{@mail.subject} Enviado"
        else 
          flash[:error] = "Email No Enviado"
        end
      else 
        flash[:error] = "Email No Encontrado"
      end
    else
      flash[:error] = "Email No Enviado"
      redirect_to :back
    end 
  end
  
  def guard_mailer(mailer)
    [:first,:second,:third].include?(mailer) && NotificationsMailer.respond_to?(mailer)
  end
  
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
        :debtor_id)
    else
      redirect_to new_user_session_path
    end
  end
  
  #TODO Method Below could be In Lib
  def log_email(mail, debt, user, options={})
    mail_log = MailLog.create(
      user_id: user.id,
      debt_id: debt.id,
      mailer_id: mail.message_id,
      mailer_name: options.fetch(:mailer_name, 'unknown'), # mailer_subject: mail.subject, 
      datetime_sent: DateTime.now,
      email_sent_to: mail.header.to_s,
      mailer_content: mail.multipart? ? mail.html_part.body.to_s : mail.body.to_s
    )
    mail_log.save or fail
  end
  
end

__END__

