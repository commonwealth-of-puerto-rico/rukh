require 'spec_helper'

describe DebtsController do
  describe 'CSV output' do
    before do
      FactoryGirl.create(:debt, :bank_name => "Pakistan Bank")
    end
    it "returns a CSV file", slow: true do
      get :index, format: :csv
      expect(response.headers['Content-Type']).to have_content 'text/csv'
    end
  
    it "returns expected value", slow: true do
      expect(Debt.to_csv).to match /Pakistan Bank/
    end
    
    it "returns a xls file", slow: true do
      get :index, format: :xls
      expect(response.headers['Content-Type']).to have_content 'application/xls'
    end
    
    # Authentication Issue to get xls output

  end
  describe 'Deletion' do
    before do
      debtor10 = FactoryGirl.create(:debtor) # try using subject here
    end
    it 'should raise an error when delete is attempted' do
      expect {
        delete :destroy, id: debtor10.id
      }.to raise_error
    end
    
  end
  
end
