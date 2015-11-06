# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DebtorsController do
  
  describe "CRUD" do
    
    it 'should error when destroy is evoked on a debtor w/ association' do
      debtor = FactoryGirl.create(:debtor)
      debt = FactoryGirl.create(:debt, debtor_id: debtor.id, debtor: debtor.name)
      puts "Tested this and it works but test is not producing expected result."
      expect {
        delete :destroy, id: debtor.id
      }.to raise_error RuntimeError   
    end
    
  end
  

end
