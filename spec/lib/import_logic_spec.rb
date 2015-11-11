# -*- encoding : utf-8 -*-
require 'spec_helper'

require 'ImportLogic'

# Generate sample CSV. 
# Import sample CSV
# Verify against test db

# Use StringIO to simulate file 
csv_test_file = File.expand_path("./spec/lib/test.csv")

describe ImportLogic do
  
  let(:imp) { ImportLogic.new(nil) }
  
  describe "Reads file" do
    before do
      # DatabaseCleaner.start
    end
    after do
      # DatabaseCleaner.clean
    end
    xit "reads number of lines correctly from actual file" do
      # testing private methods requires send
      # can't seem to make this work
      File.open(csv_test_file) { |file|
        expect(imp.send(:find_file_lines, file)).to eq(3)
      } 
    end
    xit "stores_debtor_record successfully" do
      record = test_stringio
      imp.send(
      :store_debtor_record,
      record
      )
      # check if debtor model added it
    end
    
    xit "imports file properly" do
      #Clean up test db
      import_csv(csv_test_file)
      # Expect test db to contain correct ## of records
      
    end

    
    
  end
  

  
end