# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Debt do

  ##########
  describe "Validations" do
    describe "responds to " do
      characteristics = [:permit_infraction_number, :amount_owed_pending_balance, :paid_in_full,                   
        :type_of_debt, :original_debt_date, :originating_debt_amount, :bank_name,
        :bounced_check_number, :in_payment_plan, :in_administrative_process,       
        :contact_person_for_transactions, :notes, :debtor_id, :created_at, :updated_at,
        :fimas_project_id, :fimas_budget_reference, :fimas_class_field, :fimas_program, 
        :fimas_fund_code, :fimas_account, :fimas_id, :debtor]
      characteristics.each do |type|
        it {should respond_to(type.to_sym)}
      end
    end
    
    it 'shoud validate amount owed is a number' do
      debt1 = FactoryGirl.build(:debt, amount_owed_pending_balance: nil) # or nil
      # strings get clobbered into a number so must use nil
      debt1.valid?
      expect(debt1.errors[:amount_owed_pending_balance]).to include("Debe ser un número.")
    end
    
    it 'should not allow amount owed pending balance to be nil' do
      debt1 = FactoryGirl.build(:debt, amount_owed_pending_balance: nil)
      expect(debt1).to_not be_valid   
    end
    
    it "is invalid without a debtor id" do
      expect(Debt.new(debtor_id: nil)).to_not be_valid
    end
    
    it "Contains a permit number or infraction number or it is blank" do
      expect(FactoryGirl.build(:debt,
        permit_infraction_number: "PG-GE-#{rand(10..99)}-#{rand(10..99)}-#{rand(10..99)}-#{rand(9)}")).to(be_valid) and
      expect(FactoryGirl.build(:debt,:permit_infraction_number => nil)).to(be_valid)
    end
  
    it "has a 9 digit routing number or is blank" do
      debt3 = FactoryGirl.build(:debt, bank_routing_number: rand(1111111111..9999999999))
      debt3.valid?
      expect(debt3.errors[:bank_routing_number]).to include "Deber ser un número de nueve (9) digitos o estar en blanco."
    end
    
    it "routing number can be blank"  do
      expect(FactoryGirl.build(:debt,:bank_routing_number => nil)).to be_valid
    end
    
    it "raises an error if originating date is nil" do
      debt4 = FactoryGirl.build(:debt, :original_debt_date => nil )
      debt4.valid?
      expect(debt4.errors[:original_debt_date]).to include "no puede estar en blanco"
    end
    
    it "orginating date set to nil should not be valid" do
      expect(FactoryGirl.build(:debt,:original_debt_date => nil)).to_not be_valid
    end
    
  end
  
  # describe "Procedure Specs" do
  #   skip it "Is either paid_in_full, in process or owes some $$"
  #   # Not implemented
  # end
  
  
  ## Method Specs
  
  describe "Method Specs" do
    describe "CSV creation" do  
      it 'should create a valid csv file' do
        FactoryGirl.create(:debt, :bank_name => "Pakistan Bank")
        expect(Debt.to_csv).to match /Pakistan Bank/
        # FactoryGirl.create(:debt)
        # expect(FactoryGirl.build(:debt).to_csv).to_not raise_error
      end
    end
  end
  
end
