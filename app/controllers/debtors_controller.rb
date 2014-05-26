class DebtorsController < ApplicationController
  before_action :authenticate_user! ## for DEVISE
  # before_destroy current_user.user_role.somethingsomething
  
  ## Resource Actions
  def new
    assign_current_user
    @debtor = Debtor.new
  end
  
  def create
    assign_current_user
    @debtor = Debtor.new(debtor_params) 
    if @debtor.save
      flash[:success] = "Nuevo Record de Deudor Creado."
      redirect_to @debtor
    else
      render 'new'
    end
  end
  
  def show
    assign_current_user
    @debtor = Debtor.find(params[:id]) #Should this be find_by_id?
    # cookies[:current_debtor_id] = @debtor.id
    # @collections = @debtor.collections.paginate(page: params[:page])
  end
  
  def destroy
    assign_current_user
    #Should only be certain users --> Supervisor users.
    Debtor.find(params[:id]).destroy
    flash[:success] = "Record del deudor borrado."
    redirect_to debtors_url
  end
  
  def edit
    assign_current_user
    @debtor = Debtor.find(params[:id])
  end
  
  def update
    #TODO fix form method to patch or put for SS
    #Probably related to debtor_params below
    assign_current_user
    # @debtor = Debtor.find(cookies[:current_debtor_id])
    @debtor = Debtor.find(params[:id])
    if @debtor.update_attributes(debtor_params)
      flash[:success] = "Informacion del deudor actualizada."
      redirect_to @debtor
    else
      render 'edit'
    end
  end
  
  def index
    #TODO fix pagination
    assign_current_user
    @debtors = params[:search].blank? ?  
      Debtor.paginate(page: params[:page], per_page: 10) : 
      Debtor.search(params[:search])
 
    @color_code_proc = ->(debtor_debts){debtor_debts.collect do |debt|
      debt.paid_in_full ? 0 : debt.amount_owed_pending_balance
      end.reduce(0){ |total, amount| amount + total}
    }
    #map is an alias of collect, reduce of inject and select of find_all
  end
  
  
  ## Methods
  def search
    @debtor = Debtor.search(params[:search])
  end
  
  def api_search
    respond_to do |format|
      format.html
      format.json { render json: @debtor, :callback => params[:callback] }
    end
    @debtor = Debtor.api_search(params[:search])
  end
  
  
  private
  def assign_current_user
    @user = current_user
  end
  
    def debtor_params
      if user_signed_in? #updated for Devise
        #Can be determined by role
        params.require(:debtor).permit(:name, :email, :tel, :ext, :address,
              :location, :contact_person, :contact_person_email, :employer_id_number, :ss_hex_digest)
      else
        redirect_to new_user_session_path
      end
    end
  
  
  
end
__END__
