# -*- encoding : utf-8 -*-

class DebtorsController < ApplicationController
  before_action :authenticate_user! ## for DEVISE
  # before_destroy current_user.user_role.somethingsomething

  ## Resource Actions ##
  def new
    assign_current_user
    @debtor = Debtor.new
  end

  def create
    assign_current_user
    @debtor = Debtor.new(debtor_params)
    begin
      if @debtor.save
        flash[:success] = 'Nuevo Record de Deudor Creado.'
        redirect_to @debtor
      else
        flash.now[:warning] = 'Hubo un Error. Record de Deudor No Creado.'
        render 'new'
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, ActiveRecord::JDBCError => e
      flash.now[:error] = "Error: Hay un problema con la data sometida. \t#{e.message}"
      render 'new'
    end
  end

  def show
    assign_current_user
    @debtor = Debtor.find(params[:id]) # Should this be find_by_id?
    # cookies[:current_debtor_id] = @debtor.id
    # @collections = @debtor.collections.paginate(page: params[:page])
  end

  def destroy
    assign_current_user # Should only be certain users --> Supervisor users.
    # With 'dependency: restrict' only debtors w/ no debt can be deleted.
    begin
      Debtor.find(params[:id]).destroy
      flash[:success] = 'Record del deudor borrado.'
    rescue ActiveRecord::DeleteRestrictionError => e
      flash[:error] = e
      raise e
    end
    redirect_to debtors_url
  end

  def edit
    assign_current_user
    @debtor = Debtor.find(params[:id])
  end

  def update
    # TODO: fix form method to patch or put for SS
    # Probably related to debtor_params below
    assign_current_user
    @debtor = Debtor.find(params[:id])
    begin
      if @debtor.update_attributes(debtor_params)
        flash[:success] = 'Informacion del deudor actualizada.'
        redirect_to @debtor
      else
        render 'edit'
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, ActiveRecord::JDBCError => e
      flash.now[:error] = "Error: Hay un problema con la data sometida. \t#{e.message}"
      render 'new'
    end
  end

  def index
    assign_current_user
    @debtors =
      if params[:search].blank?
        Debtor.paginate(page: params[:page], per_page: 10)
      else
        Debtor.search(params[:search])
      end
    @color_code_proc = lambda { |debtor_debts|
      debtor_debts.collect do |debt|
        debt.paid_in_full ? 0 : debt.amount_owed_pending_balance
      end.reduce(0) { |total, amount| amount + total }
    }
  end

  ## Additional Methods ##
  def search
    @debtor = Debtor.search(params[:search])
  end

  ## API Search Stub for integration with other systems
  # TODO Add security and finalize
  def api_search
    # TODO: add a limit to the debtor info sent by json.
    respond_to do |format|
      format.html
      format.json { render json: @debtor, callback: params[:callback] }
    end
    @debtor = Debtor.api_search(params[:search])
  end

  private

  def assign_current_user
    @user = current_user
  end

  def debtor_params
    if user_signed_in? # updated for Devise
      # Can be determined by role
      # TODO add last SS permit and logic above
      params.require(:debtor).permit(:name, :email, :tel, :ext, :address,
                                     :location, :contact_person, :contact_person_email, :employer_id_number, :ss_hex_digest)
    else
      redirect_to new_user_session_path
    end
  end
end

