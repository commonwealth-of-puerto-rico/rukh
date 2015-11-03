# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'stringio'
require 'ImportLogic'

# Generate sample CSV. 
# Import sample CSV
# Verify against test db

# Use StringIO to simulate file  # For some reason StringIO::Open not liking me

test_stringio = StringIO.new(
"id,permit_infraction_number,amount_owed_pending_balance,paid_in_full,type_of_debt,original_debt_date,originating_debt_amount,bank_routing_number,bank_name,bounced_check_number,in_payment_plan,in_administrative_process,contact_person_for_transactions,notes,debtor_id,created_at,updated_at,fimas_project_id,fimas_budget_reference,fimas_class_field,fimas_program,fimas_fund_code,fimas_account,fimas_id,debtor_name
1,PGGE1212127,1000.0,false,,2015-09-23,1000.0,,,1234,false,false,,alskf,1,2015-09-16 16:09:03 -0400,2015-09-16 16:09:03 -0400,asflk,af,adf,af,af,afd,,Test
2,rtrt1313134,25.0,false,,2015-10-23,25.0,,,12,false,false,,afd,2,2015-10-15 00:42:32 -0400,2015-10-15 00:42:32 -0400,'','','','','','',,El Feísimo")
csv_test_file = File.expand_path "./spec/lib/test.csv"

describe ImportLogic do
  
  let(:imp) { ImportLogic.new(nil) }
  
  describe "Import Support module" do
    it "guesses UTF8 from UTF8 file" do 
      # This doesn't rewind string io fyi
      expect(imp.check_utf_encoding(test_stringio.read)).to eq("UTF-8")
    end
    
    it "sanitizes_row" do
      expect(imp.sanitize_row({bobbytables: "Robert'); DROP TABLE DEBTS; --", 
        coma: "Simple-text, comma,"})).to eq(bobbytables: "Robert DROP TABLE DEBTS --", coma: "Simple-text comma")
    end
    
    it "blank_out_fields puts an empty string on nil values" do
      expect(imp.blank_out_fields({nil: nil, :'not-nil' => "nil"}, [:nil])).to eq({nil: '', :'not-nil' => "nil"})
    end
    
    it "blank_out_fields to ignore values not in fields" do
      expect(imp.blank_out_fields({nil: nil, :'not-nil' => "nil"}, [:'not-nil'])).to eq({nil: nil, :'not-nil' => "nil"})
    end
    
    it "reads number of line from stringio file" do
      test_stringio.rewind
      expect(imp.find_number_lines(test_stringio)).to eq(3)
    end
    
    it "reads number of lines from actual opened file (slow)", slow: true, file: true do
      #slow 
      expect(File.open(csv_test_file, "r") {|f| imp.find_number_lines(f)}).to eq(3)
    end

  end
  
  describe "Reads file" do
    it "reads number of lines correctly from actual file" do
      # testing private methods requires send
      expect(imp.send(:find_file_lines, csv_test_file)).to eq(3)
    end
    it "deletes all keyes except array" do
      expect(imp.send(
      :delete_all_keys_except, 
      {one: 1, two: 2, three: 3},
      [:one, :two])).to eq({one: 1, two: 2})
    end
    xit "stores_debtor_record successfully" do
      record = test_stringio
      imp.send(
      :store_debtor_record,
      record
      )
       
    end
    
    xit "imports file properly" do
      import_csv(csv_test_file)
      
    end
    
    
  end
  

  
end