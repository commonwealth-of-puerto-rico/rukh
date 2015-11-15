# -*- encoding : utf-8 -*-
require 'spec_helper'

require 'ImportLogic'

# Generate sample CSV. 
# Import sample CSV
# Verify against test db

csv_test_file = File.expand_path("./spec/lib/test.csv")

describe ImportLogic do

  let(:imp) { ImportLogic.new(nil) }

  describe "Reads file" do

    # after do
    #   if (Debt.any? or Debtor.any?)
    #     puts "reseting DB ==> super slow"
    #     if `rake db:reset RAILS_ENV="test"`
    #       puts "reset DB ==> super slow"
    #     end
    #   end
    # end
    it "process CSV file properly" do
      skip "This Test Can only be run in isolation."
      if `rake db:reset RAILS_ENV="test"`
        if imp.send(:process_CSV_file, File.new(csv_test_file), 3, "bom|utf-8")
          imp.terminate
        end
        expect(Debt.count).to eq(2)
      end
    end

  end
end