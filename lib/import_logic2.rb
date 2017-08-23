# frozen_string_literal: true

# require 'sucker_punch'
require 'sucker_punch/async_syntax'
require 'cmess/guess_encoding'
require 'smarter_csv'

class ImportLogic2
  # include SuckerPunch::Job
  
  def self.import_csv(file)
    file_lines = FindFileLines.new.perform(file)
    char_set   = CheckEncoding.new.perform(file.tempfile)
    ProcessCSV.new.perform(file.tempfile, file_lines, char_set)
  end
end

class FindFileLines
  include SuckerPunch::Job

  def perform(file)
    file.open { |f| find_number_lines(f) }
  end

  def find_number_lines(opened_file)
    start_time = Time.now.to_i
    total_file_lines = opened_file.each_line.inject(0) { |total, _amount| total + 1 }
    opened_file.rewind
    if Rails.env.development?
      end_time = Time.now.to_i
      puts("1. Lines ==> #{total_file_lines} in #{((end_time - start_time) / 60).round(2)}")
    end
    total_file_lines
  end
end

class CheckEncoding
  include SuckerPunch::Job

  def perform(file)
    input = File.read(file)
    CMess::GuessEncoding::Automatic.guess(input)
  end
end

class ProcessCSV
  include SuckerPunch::Job

  def sanitize_row(record)
    # first exchanges \ for - then removes everything not[^ ] :word or - or . or space
    # put sql problem chars here only.gsub(/\W+/, ""))
    cleaned_record = {}
    record.each_pair do |k, v|
      cleaned_record.store(k,
                           v.to_s.gsub(/\//i, '-').gsub(/[^ [:word:]\-\. ]/i, ''))
    end
    cleaned_record
  end

  def perform(file, file_lines, char_set)
    start_time = Time.now.to_i # setting up time keeping
    counter = []
    ActiveRecord::Base.connection_pool.with_connection do
      ActiveRecord::Base.transaction do
        SmarterCSV.process(file,
                           chunk_size: 10,
                           verbose: true,
                           file_encoding: char_set.to_s) do |file_chunk|
          file_chunk.each do |record_row|
            sanitized_row = sanitize_row(record_row)
            ProcessRecord.new.perform(sanitized_row, {})
            counter << sanitized_row # appends in latest record to allow error to report where import failed
            puts "\033[32m#Processed Record No. {counter.size}\033[0m\n"
            counter
          end
        end
      end
      # LogJob.perform_async("User #{user.id} became awesome!") # for progress bar?
    end
    end_time = Time.now.to_i
    puts "Total time to import #{((end_time - start_time) / 60).round(2)}"
  end
end

class ProcessRecord
  include SuckerPunch::Job

  def debtor_id_process(record, debtor_id, debt_id)
    if !record.fetch(:id).strip.downcase['null'] &&
       Debt.find_by_id(debt_id)
      ## Update action overwrites
      ## Update Debt
      record[:debtor_id] = debtor_id.to_i
      update_debt_record(record, update: true, id: debt_id)
    elsif !record.fetch(:id).strip.downcase['null']
      record[:debtor_id] = debtor_id.to_i
      store_debt_record(record)
    else
      # TODO: change fails into Flash message by using ImportError
      fail "Can't Update Record without matching IDs"
    end
  end
  
  @@debt_headers_array = %i[
    id
    permit_infraction_number
    amount_owed_pending_balance
    paid_in_full
    type_of_debt
    original_debt_date
    originating_debt_amount
    bank_routing_number
    bank_name
    bounced_check_number
    in_payment_plan
    in_administrative_process
    contact_person_for_transactions
    notes
    debtor_id
    fimas_project_id fimas_budget_reference
    fimas_class_field fimas_program
    fimas_fund_code fimas_account fimas_id
  ]
  @@debtor_headers_array = %i[id employer_id_number name tel email address location contact_person]

  def store_debt_record(record, debt_array = @@debt_headers_array)
    store_one_record(record, debt_array, Debt)
  end

  def store_debtor_record(record, debt_array = @@debt_headers_array)
    store_one_record(record, debtor_array,
                     Debtor) { |debtor_record| debtor_record[:contact_person] = debtor_record[:name] }
  end

  def update_debt_record(record, id, debtor_array = @@debtor_headers_array)
    store_one_record(record, debt_array, Debt, update: true, id: id, debt: true)
  end
  
  def store_one_record(record, inc_array, model, options = { create: true }, &block)
    clean_record = delete_all_keys_except(record, inc_array)
    # id = record.fetch(:id).to_i
    yield(clean_record) if block
    if options[:create]
      model.create(clean_record)
    elsif options[:update]
      id = if options[:debt]
             record[:id]
           else
             record[:debtor_id]
           end
      # up_record = {id => clean_record}
      model.update(id, clean_record)
    else
      fail 'No valid option given'
    end
    # if succeeds...
  end
  
  ## To clean up a hash with only permited keys
  def delete_all_keys_except(hash_record,
                             except_array = [])
    hash_record.select do |key|
      except_array.include?(key)
    end
  end
  
  def debtor_in_db_already(record, db_Debtor = Debtor)
    puts 'Verifying if record contains a debtor already in db'
    if record[:debtor_id] && db_Debtor.find_by_id(record.fetch(:debtor_id))
      puts 'Searching db by ID'
      debtor = Debtor.find(record.fetch(:debtor_id))
    elsif record[:employer_id_number] &&
          Debtor.find_by_employee_id_number(record.fetch(:employer_id_number))
      puts 'Searching db by EIN'
      debtor = Debtor.find_by_employee_id_number(record.fetch(:employer_id_number))
    elsif record[:debtor_name] && !record.fetch(:debtor_name).strip.downcase['null']
      puts "NAME SEARCH for #{record[:debtor_name]}"
      debtor = Debtor.find_by_name(record.fetch(:debtor_name))
    else
      debtor = nil
    end
    debtor.blank? ? false : debtor.id
  end

  def perform(record, _options = {})
    debtor_id = debtor_in_db_already(record)
    debt_id = record.fetch(:id, 0).to_i

    if debtor_id
      debtor_id_process(record, debtor_id, debt_id)
    elsif record[:debtor_id] &&
          !record.fetch(:debtor_id).strip.downcase['null']
      ## TODO: merge hash to add missing keys
      ## TODO: Blank out nil values to empty strings:
      ## TODO # debtor_record = add_missing_keys(record, debtor_array)

      ## Store Debtor
      debtor_record = record
      debtor_record[:name] = record[:debtor_name]
      # Debtor update not working.
      debtor = store_debtor_record(debtor_record)

      ## Store Debt
      record[:debtor_id] = debtor.id
      store_debt_record(record)
    else
      # TODO: change fails into Flash message by using ImportError
      fail "Can't understand import record: #{record}"
    end
  end
end
