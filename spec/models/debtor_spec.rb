# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'faker'

describe Debtor do
  let(:happy_zombie_debtor) {
    Debtor.new(name: 'Zombie Debtor Test', email: 'goodemail@example.com', tel: '7877877879', contact_person: "me",
    ext: 'x789', address: '#1 Nippon', location: 'Esquina', contact_person_email: "good_email@example.com", 
    employer_id_number: "12-1234567", uses_personal_ss: false)
  }
  let(:unhappy_zombie_debtor) {
    Debtor.new(name: 'Zombie Test', email: 'bademail', tel: '787-787-7879', contact_person: nil,
    ext: nil, address: nil, location: nil, contact_person_email: "@example.com",
    employer_id_number: "12-1234567", uses_personal_ss: true, ss_hex_digest: "5656565656656",
    ss_last_four: "12345")
  }
  subject { happy_zombie_debtor }
  
  ###########
  describe "Validations" do 
    
    describe "responds to " do
      characteristics = [:name, :email, :tel, 
        :ext, :address, :location, :contact_person,
        :contact_person_email, :employer_id_number, 
        :ss_hex_digest, :ss_last_four, :uses_personal_ss]
      characteristics.each do |type|
        it {should respond_to(type.to_sym)}
      end
    end
    
    it 'happy debtor path should be valid' do
      expect(happy_zombie_debtor).to be_valid
    end
    it 'factory happy debtor path should be valid' do
      expect(FactoryGirl.build(:debtor)).to be_valid
    end
    
    it "contains either an ein or a ss but not both" do
      happy_zombie_debtor.uses_personal_ss = true
      happy_zombie_debtor.ss_hex_digest = "5656565656656"
      happy_zombie_debtor.valid?
      # es.activerecord.errors.models.debtor.attributes.employer_id_number.present
      expect(happy_zombie_debtor.errors[:employer_id_number]).to include(
      "No pueden haber ambos un número de Seguro Social Patronal y uno Personal")
    end
    
    it "returns false for uses_personal_ss if ien present" do
      expect(happy_zombie_debtor.employer_id_number.nil?).to(eq(false)) and
      expect(happy_zombie_debtor.uses_personal_ss).to(eq(false)) ? true : false
    end
    
    it "contains a contact person" do
      unhappy_zombie_debtor.valid?
      expect(unhappy_zombie_debtor.errors[:contact_person]).to include "no puede estar en blanco"
    end
    
  end 
   
  describe "Invalidations" do
    
    it "rejects bad emails addresses" do
      happy_zombie_debtor.email = 'bademail'
      happy_zombie_debtor.valid?
      expect(happy_zombie_debtor.errors[:email]).to include "Email invalido" # or more
    end
    it "rejects bad emails addresses (both for company and contact person)" do
      unhappy_zombie_debtor.valid?
      expect(unhappy_zombie_debtor.errors[:contact_person_email]).to include "Email invalido" # or more
    end
    describe "when EIN is invalid" do
      it "should be invalid" do
        unhappy_zombie_debtor.employer_id_number = '55-9'
        expect(unhappy_zombie_debtor).not_to be_valid
      end
    end
  
    it "rejects two debtors with same ss" do
      debtor2 = FactoryGirl.build(:debtor, ss_hex_digest: "123-12-1234", employer_id_number: nil)
      happy_zombie_debtor.ss_hex_digest = "123-12-1234"
      happy_zombie_debtor.save!(validate: false)
      expect{ debtor2.save!(validate: true) }.to raise_error ActiveRecord::RecordNotUnique
    end
    
    it 'is invalid if it has both ein and ss' do
      expect(FactoryGirl.build(:debtor, ss_hex_digest: "123-12-1234")).to_not be_valid
    end
  
  end
  
  it "cleans up telephone number" do
    expect(happy_zombie_debtor.tel.to_i).to eql(7877877879)
  end
  it "cleans up tel number 2" do
    expect(unhappy_zombie_debtor.tel.to_i).to_not eql(7877877879)
  end
  it 'cleans up tel number 3' do
    expect(unhappy_zombie_debtor.tel.each_char.select{|x| x.match(/[0-9]/)}.join('').to_i).to \
      eql(7877877879)     
  end
  ####### Search Function
  describe 'clean_up_search_term_method' do
    it 'should return HexString for ss xxx-xx-xxxx number' do
      expect(Debtor.clean_up_search_term('123-12-1234')).to be_a_kind_of(HexString)
    end
    it 'should return FixNum for ein xx-xxxxxxx number' do
      expect(Debtor.clean_up_search_term('12-1234567')).to be_a_kind_of(Integer)
    end
    it 'should return String for anything else' do
      expect(Debtor.clean_up_search_term('Miguel Rios')).to be_a_kind_of(String)
    end
    describe 'search -clean_up_search_term- should handle garbage data' do
      it 'garbage data1' do
        expect{Debtor.clean_up_search_term(1.000003)}.to_not raise_error
      end
      it 'garbage data2' do
        expect{Debtor.clean_up_search_term(/fail/)}.to_not raise_error 
      end
      it 'garbage data3'do
        expect(Debtor.clean_up_search_term(/fail/)).to be_a_kind_of(String)
      end
    end
  end
  
  describe 'search' do
    it "Debtor should respond to search" do
      expect(Debtor.respond_to?(:search)).to be true
    end
    skip describe 'looking in the db' do
      it 'should search via ss'
      it 'should search via ein' do
        expect(Debtor.search("12-1234567")).to eq(happy_zombie_debtor)
      end
      it 'should search via HexString of ss'
      it 'should search via name' do
        expect(Debtor.search('Zombie Debtor Test')).to eq(happy_zombie_debtor)
      end
      it 'should fail when given FLOAT' do
        expect(Debtor.search(1.0)).to raise_error RuntimeError, /unknown type/i
      end 
    end    
  end
  describe 'private methods' do
    it 'last for should strip last four digits of a string of digits' do
      expect(unhappy_zombie_debtor.send(:last_four, "123bbadfaf-134-adfa-123")).to eq "4123"
    end
    it 'removes hyphens from string and leaves only digits' do
      expect(Debtor.send(:remove_hyphens, "123bbadfaf-134-adfa-123")).to eq "123134123"
    end
    it 'produces an encrypted string' do
      expect(Debtor.send(:encrypt, "123456789")).to be_kind_of String
    end
    it 'produces an encrypted string not the same as original string' do
      expect(Debtor.send(:encrypt, "123456789")).to_not eq("123456789")
    end
  end
  
end


