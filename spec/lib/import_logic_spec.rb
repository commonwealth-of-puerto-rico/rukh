# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'database_cleaner'

require 'ImportLogic'

# Generate sample CSV. 
# Import sample CSV
# Verify against test db

csv_test_file = File.expand_path("./spec/lib/test.csv")

DatabaseCleaner.strategy = :transaction

describe ImportLogic do
  
  let(:imp) { ImportLogic.new(nil) }
  
  describe "Reads file" do
    after do
      if (Debt.any? or Debtor.any?)
        puts "reseting DB ==> super slow"
        `rake db:reset RAILS_ENV="test"`
      end
    end
    
    it "process CSV file properly" do
      # Clean up test db
      if (Debt.any? or Debtor.any?)
        puts "reseting DB ==> super slow"
        `rake db:reset RAILS_ENV="test"`
      end
      imp.send(:process_CSV_file, File.new(csv_test_file), 3, "bom|utf-8")
      expect(Debt.count).to eq(2)
    end
    
  end
end