# -*- encoding : utf-8 -*-

require 'mail_support'

# rubocop:disable Metrics/ClassLength
class DebtsController < ApplicationController
  before_action :authenticate_user! ## for DEVISE
  include MailSupport

  ## Resource Actions ##
  def new
    assign_current_user
    @debtor = Debtor.find_by_id(params[:debtor_id])
    @debt = Debt.new
  end

  def edit
    assign_current_user
    @debt = Debt.find_by_id(params[:id])
    @debtor = Debtor.find_by_id(@debt.debtor_id)
  end

  def show
    assign_current_user
    @debt = Debt.find_by_id(params[:id])
    @debtor = Debtor.find_by_id @debt.debtor_id
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
      flash[:success] = 'Nueva Factura Creada'
      redirect_to @debt
    else
      flash[:error] = 'Factura No Gravada'
      render 'new'
    end
  end

  def update
    assign_current_user
    @debt = Debt.find_by_id(params[:id])
    @debtor = Debtor.find_by_id(@debt.debtor_id)
    @debt.permit_infraction_number = strip_hyphens(@debt.permit_infraction_number)
    if @debt.update_attributes(update_debt_params) && @debt.valid?
      flash[:success] = 'Factura Actualizada'
      redirect_to @debt
    else
      flash[:error] = 'Factura No Actualizada'
      render 'edit'
    end
  end

  ## Index ##
  #  Index of all debt and XLS & CSV export
  #  Responds to xls and csv format and uses pagination
  def index
    assign_current_user
    case params['format']
    when 'csv', 'xls', 'xlsx'
      @debts_all = Debt.all
    else
      @debts_all = Debt.paginate(page: params[:page], per_page: 10)
    end
    respond_to do |format|
      format.html
      format.xls
      format.xlsx
      format.csv { send_data @debts_all.to_csv }
    end
  end

  ## Emails ##
  def preview_email
    @debt = Debt.find_by_id(mailer_params[:id])
    @user = current_user
    @mailer = mailer_params[:mailer].to_sym
    @date_first_email_sent = date_first_email_sent(@debt)
    @print = mailer_params[:print] == 'true' ? true : false
    prepare_email(@debt, @user, @mailer, preview: true,
                                         date_first_email_sent: @date_first_email_sent,
                                         display_attachments: false)
    render layout: false
  end

  def send_email # should be Post only
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

  ## Controller Private Methods ##
  def assign_current_user
    @user = current_user
  end

  def mailer_params
    if user_signed_in? # Devise
      # If only used for sending can validate user role
      params.permit(
        :mailer,
        :id,
        :print
      )
    else
      flash[:error] = 'Usuario No autorizado.'
      redirect_to :back
    end
  end

  def debt_params
    if user_signed_in? # updated for Devise
      # Can be determined by role
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
        :fimas_account
      )
    else
      redirect_to new_user_session_path
    end
  end

  def update_debt_params
    if user_signed_in? # updated for Devise
      # Can be determined by role
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
        :notes
      )
    else
      redirect_to new_user_session_path
    end
  end
end
