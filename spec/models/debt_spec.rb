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
      # strings get clobbered into a number so must use nil
      debt1 = FactoryGirl.build(:debt, amount_owed_pending_balance: nil) # or nil
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
  
  ## Method Specs
  describe "Method Specs" do
    describe "find_debtor_attribute works" do
      let(:subject) { FactoryGirl.build(:debt) }
      it 'should return name' do
        FactoryGirl.create(:debtor, :name => "Mark Twain", :id => 233)
        expect(subject.find_debtor_attr(233, [:name])).to eq(["Mark Twain"])
      end
      it 'should return contact name' do
        FactoryGirl.create(:debtor, :contact_person => "Samuel Clemens", :id => 234)
        expect(subject.find_debtor_attr(234, [:contact])).to eq(["Samuel Clemens"])
      end
      it 'should returns array of name and contact name' do
        FactoryGirl.create(:debtor, :contact_person => "Samuel Clemens", :name => "Mark Twain", :id => 236)
        expect(subject.find_debtor_attr(236, [:name ,:contact])).to eq(["Mark Twain", "Samuel Clemens"])
      end
      it 'should fail if given anything other to search for'do
        FactoryGirl.create(:debtor, :email => "MarkTwain@example.com", :id => 235)
        expect { subject.find_debtor_attr(235, [:email])}.to raise_error(KeyError)
      end
    end
  
    describe "CSV creation" do  
      it "shouldn't error'" do
        expect {Debt.to_csv}.not_to raise_error
      end
      it 'should create a valid csv file' do
        expect(Debt.to_csv.chomp).to eq(
        "id,permit_infraction_number,amount_owed_pending_balance,paid_in_full,type_of_debt,original_debt_date,originating_debt_amount,bank_routing_number,bank_name,bounced_check_number,in_payment_plan,in_administrative_process,contact_person_for_transactions,notes,debtor_id,created_at,updated_at,fimas_project_id,fimas_budget_reference,fimas_class_field,fimas_program,fimas_fund_code,fimas_account,fimas_id,debtor_name,contact_person")
      end
    end
  end
  
end
