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
  
end

__END__

