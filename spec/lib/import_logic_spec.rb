# -*- encoding : utf-8 -*-

require 'spec_helper'

require 'ImportLogic'

# Generate sample CSV.
# Import sample CSV
# Verify against test db

describe ImportLogic do
  let(:imp) { described_class.new(nil) }
  let(:csv_test_file) { File.expand_path('./spec/lib/test.csv') }

  describe 'Reads file' do
    before do
    end
    after do
    end

    it 'process CSV file properly' do
      skip 'This Test Can only be run in isolation. Because it uses Threads. And locks the SQlite db.'

      if `rake db:reset RAILS_ENV="test"`

        if imp.send(:process_CSV_file, File.new(csv_test_file), 3, 'bom|utf-8')
          imp.terminate
        end
        puts 'Finishes Import Checking Result'
        expect(Debt.count).to eq(2)

      end
    end
  end
end
