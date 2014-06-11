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
    @debt = Debt.find_by_id(params[:id])
    @user = current_user
    @mailer = params[:mailer].to_sym
    #TODO Create logic here to mark which notification to send.
    if NotificationsMailer.respond_to?(@mailer) && [:first,:second,:third].include?(@mailer)
      @preview = NotificationsMailer.public_send(@mailer, @debt, @user)
    else 
      flash[:error] = "Email No Enviado"
      # redirect_back
    end
    # @preview.body_encoding('utf-8')
    # @preview.to_s.force_encoding('utf-8')
    render layout: false #TODO create layout for emails w/ send
  end
  
  def send_email #should be Post only
    @debt = Debt.find_by_id(params[:id])
    @user = current_user
    @mailer = params[:mailer].to_sym
    #TODO Create logic here to mark which notification to send.
    if NotificationsMailer.respond_to?(@mailer) && [:first,:second,:third].include?(@mailer)
      @mail = NotificationsMailer.public_send(@mailer, @debt, @user)
      if @mail.deliver
        log_email(@mail, @debt, @user)
        # LogMail.log_email(@mail, @debt, @user) #TODO refactor to lib
        flash[:success] = "Email: #{@mail.subject} Enviado"
      else 
        flash[:error] = "Email No Enviado"
      end
    else 
      fail
    end
    #log action
    redirect_to @debt
  end
  
  private
  def assign_current_user
    @user = current_user
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
  def log_email(mail, debt, user)
    mail_log = MailLog.create(
      user_id: user.id,
      debt_id: debt.id,
      mailer_id: mail.message_id,
      mailer_name: mail.subject,
      datetime_sent: DateTime.now,
      email_sent_to: mail.header.to_s,
      mailer_content: mail.body.to_s
    )
    mail_log.save or fail
  end
  
end

__END__

