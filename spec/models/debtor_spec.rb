require 'spec_helper'

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
    
    it "contains either an ein or a ss but not both"
    
    it "returns false for uses_personal_ss if ien present" do
      expect(happy_zombie_debtor.employer_id_number.nil?).to eq false
      expect(happy_zombie_debtor.uses_personal_ss).to eq false
    end
    
    it "contains a contact person" do
      #Learn new syntax
      expect(unhappy_zombie_debtor.errors_on(:contact_person).size).to eq 1
    end
    
    
    it "cleans up telephone number" do
      expect(happy_zombie_debtor.tel.to_i).to eql(7877877879)
      expect(unhappy_zombie_debtor.tel.to_i).to_not eql(7877877879)
      expect(unhappy_zombie_debtor.tel.each_char.select{|x| x.match(/[0-9]/)}.join('').to_i).to \
        eql(7877877879)     
    end
  end 
   
  describe "Invalidations" do
    
    it "rejects bad emails addresses (both for company and contact person)" do
      expect(unhappy_zombie_debtor.errors_on(:email).size).to eq 1 # or more
      expect(unhappy_zombie_debtor.errors_on(:contact_person_email).size).to eq 1 # or more
    end
    describe "when EIN is invalid" do
      it "should be invalid" do
        unhappy_zombie_debtor.employer_id_number = '55-9'
        expect(unhappy_zombie_debtor).not_to be_valid
      end
    end
  
    it "rejects two debtors with same ss" 
    it 'rejects two debtors with same name'
  
  end
  
  ####### Search Function
  describe 'clean_up_search_term_method' do
    it 'should return HexString for ss xxx-xx-xxxx number' do
      expect(Debtor.clean_up_search_term('123-12-1234')).to be_a_kind_of(HexString)
    end
    it 'should return FixNum for ein xx-xxxxxxx number' do
      expect(Debtor.clean_up_search_term('12-1234567')).to be_a_kind_of(Fixnum)
    end
    it 'should return String for anything else' do
      expect(Debtor.clean_up_search_term('Miguel Rios')).to be_a_kind_of(String)
    end
    describe 'garbage data' do
      it 'should handle garbage data' do
        # expect(Debtor.clean_up_search_term(1.000003)).to_not raise_error
        expect(Debtor.clean_up_search_term(/fail/)).to_not   raise_error #TODO this is not working
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
  
end


