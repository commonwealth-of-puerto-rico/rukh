require 'spec_helper'

describe Debt do
  #TODO how do I link two models? so I can check Debt.debor_id.name
  let(:happily_owed_debt) {
    Debt.new(debtor_id: 1, :amount_owed_pending_balance => "12.00")
  }

  ##########
  describe "Validations" do
    describe "responds to " do
      characteristics = [:permit_infraction_number, :amount_owed_pending_balance, :paid_in_full,                   
        :type_of_debt, :original_debt_date, :originating_debt_amount, :bank_name,
        :bounced_check_number, :in_payment_plan, :in_administrative_process,       
        :contact_person_for_transactions, :notes, :debtor_id]
      characteristics.each do |type|
        it {should respond_to(type.to_sym)}
      end
    end
    
    it 'shoud validate amount owed is a number' do
      expect(Debt.new(:amount_owed_pending_balance => "hello world", debtor_id: 1)).to_not be_valid
       # expect(Debt.new(:amount_owed_pending_balance => "hello world", debtor_id: 1)).to raise_error
      # expect(Debt.new(:amount_owed_pending_balance => 12.12, debtor_id: 1)).to be_valid
    end
    
    it "is invalid without a debtor id" do
      expect(Debt.new(debtor_id: nil)).to_not be_valid
    end
    
  end
  
  it "Contains a permit number or infraction number"
  it "Is either paid_in_full, in process or owes some $$"
  it "has a valid amount owed"
  it "has a unique internal id number (from the worksheet)"
  it "has a valid internal id number-- permit number"
  
  
  #Method Specs
  
  describe "Method Specs" do
    describe "CSV creation" do
      it 'should create a valid csv file' do
        expect(happily_owed_debt.to_csv).to_not raise_error
      end
    end
  end
  
end
