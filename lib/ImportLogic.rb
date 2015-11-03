# -*- encoding : utf-8 -*-
## External GEMs
require 'cmess/guess_encoding' 
require 'smarter_csv' 
require 'celluloid/current'
require 'thread'

#TODO it's done half way due to change requirements


## This method is an actor whose purpose is to querry the actor doing the updating
## and update the progress bar on the UI. I am thinking of using SSE events to do the 
## updating.
class ProgressBarUpdater
  include Celluloid
  def initialize
    #socket?
  end
  def run(actor)
    #stub
    puts "UPDATER!!?"
    puts actor.current_progress
    true
  end
end

## Module with helper methods for importing
module ImportSupport  
  
  #spec: input::String w/ address to file
  def check_utf_encoding(input)
    require 'cmess/guess_encoding'
    CMess::GuessEncoding::Automatic.guess(input)
  end
  
  ## Iterate over each value and strip any Dangerous SQL 
  ## hash :key sanitation happens w/ a merge later on
  def sanitize_row(record)
    cleaned_record = {}
    record.each_pair do |k,v| #this might remove too much info...
      cleaned_record.store(k, 
        v.to_s.gsub(/\//i, '-').gsub(/[^ [:word:]\-\. ]/i, '') )
        # first exchanges \ for - then removes everything not[^ ] :word or - or . or space
        # put sql problem chars here only.gsub(/\W+/, ""))
    end
    cleaned_record
  end
  
  ## Blank out fields if record[field] is nil
  ## It only reads syms in fields to prevent reading injected fields on record
  def blank_out_fields(record, fields)
    fields.to_a.each do |field|
      if record[field.to_sym].nil?
        record[field.to_sym] = '' 
      end
    end
    record
  end
  def find_number_lines(opened_file)
    start_time       = Time.now
    total_file_lines = opened_file.each_line.inject(0){|total, amount| total += 1} 
    opened_file.rewind
    end_time         = Time.now
    # puts "1. Lines ==> #{total_file_lines} in #{((end_time - start_time) / 60).round(2)}"
    total_file_lines
  end 
  
end

# Import should initiallize an actor obj that gets sent the file name to import as a msg. 
# one actor per import patern allowing multiple ones. 
# There should be an import mutex lock since only one import job should be done at a time.
class ImportLogic
  include Celluloid
  include ImportSupport
  
  @@debt_header = [
       :permit_infraction_number,
       :amount_owed_pending_balance,
       :paid_in_full,
       :type_of_debt,
       :original_debt_date,
       :originating_debt_amount,
       :bank_routing_number,
       :bank_name,
       :bounced_check_number,
       :in_payment_plan,
       :in_administrative_process,
       :contact_person_for_transactions,
       :notes,
       :debtor_id,
       :fimas_project_id,  :fimas_budget_reference,
       :fimas_class_field, :fimas_program,
       :fimas_fund_code,   :fimas_account,
       :fimas_id
    ]
  @@debtor_array=[:employer_id_number,:name,:tel,:email,:address,:location,:contact_person]
  
  def initialize(updater_actor)
    @updater_actor = updater_actor
    @counter = []
    @total_lines = 0
    @exit_status = 1
  end
  
  def import_in_progress?
    #Check Mutex mutex.try_lock
  end
  def current_progress
    puts @counter.inspect
  end
  def exit_status
    @exit_status
  end
  
  def import_csv(file)
    file_lines   = find_file_lines(file)
    @total_lines = file_lines
    char_set     = check_utf_encoding(File.read(file.tempfile))
    process_CSV_file(file.tempfile, file_lines, char_set)
  end
  
  
  private
  def find_file_lines(file)
    File.open(file, "r") {|f| find_number_lines(f) }
  end 

  ## Main import method. Uses an active record transaction (if it fails the whole thing 
  ## is rolled back) to prevent partial importing
  def process_CSV_file(file, total_lines = 0, charset="bom|utf-8")
    begin 
      start_time = Time.now # setting up time keeping 
      ActiveRecord::Base.transaction do
        SmarterCSV.process(file, {:chunk_size => 10, verbose: true, file_encoding: "#{charset}" } ) do |file_chunk|
          file_chunk.each do |record_row|
            sanitized_row = sanitize_row(record_row)
            process_record_row(sanitized_row, {})
            @counter << sanitized_row # appends in latest record to allow error to report where import failed
              ### CallingActorInUpdater
              @updater_actor.run(Celluloid::Actor.current)
            @counter
          end
        end
        # finishing up time keeping and reporting:
        total_count, end_time = @counter.size, Time.now  
        total_count_hash = { total_lines: total_count, time: ((end_time - start_time) / 60 ).round(2) }
        @exit_status = "#{total_count_hash}"
        puts "\033[32m#{total_count_hash}\033[0m\n"
      end
      
    ensure
      # CSV::MalformedCSVError
      # something gets said
      @updater_actor.terminate
    end   
  end
  
  def process_record_row(record, options={})
    if debtor_in_db_already(record)
      fail "Updating Records not implemented" # Updating record #Requires updated_at field check
    elsif record[:debtor_id] && 
        !record.fetch(:debtor_id).strip.downcase['null']
      # Then Create Debtor from Record
      ## TODO: merge hash to add missing keys
      ## TODO:Blank out nil values to empty strings:
      ## Store Debtor
      ## Store Debt
      
      # debtor_record = add_missing_keys(record, debtor_array)
      
      debtor_record = record
      debtor_record[:name] = record[:debtor_name]
      debtor = store_debtor_record(debtor_record)
      record[:debtor_id] = debtor.id
      store_record(record)
    else
      fail "Can't understand import record: #{record}"
    end    
  end
  
  def store_record(record, debt_array=[])
    debt_array = [
       :permit_infraction_number,
       :amount_owed_pending_balance,
       :paid_in_full,
       :type_of_debt,
       :original_debt_date,
       :originating_debt_amount,
       :bank_routing_number,
       :bank_name,
       :bounced_check_number,
       :in_payment_plan,
       :in_administrative_process,
       :contact_person_for_transactions,
       :notes,
       :debtor_id,
       :fimas_project_id,  :fimas_budget_reference,
       :fimas_class_field, :fimas_program,
       :fimas_fund_code,   :fimas_account,
       :fimas_id
    ]
    debt_record = delete_all_keys_except(record, debt_array)
    puts debt_record
    Debt.create(debt_record)
    #if succeeds...
  end
  
  def store_debtor_record(record, debtor_array=[])
    debtor_array=[:employer_id_number,:name,:tel,:email,:address,:location,:contact_person]
    debtor_record = delete_all_keys_except(record, debtor_array)
    debtor_record[:contact_person] = debtor_record[:name]
    Debtor.create(debtor_record)
    #if succeeds...
  end
  
  def store_record(record, inc_array, model)
    clean_record = delete_all_keys_except(record, inc_array)
    yield clean_record
    model.create(clean_record)
  end
  
  def delete_all_keys_except(hash_record, 
      except_array= [])
    hash_record.select do |key|
      except_array.include?(key)
    end
  end
  
  def debtor_in_db_already(record, db_Debtor=Debtor)
    puts "Verifying if record contains a debtor already in db"
    case 
    when record[:debtor_id] && db_Debtor.find_by_id(record.fetch(:debtor_id))
      puts "Searching db by ID"
      debtor = Debtor.find(record.fetch(:debtor_id))
    when record[:employer_id_number] && 
        Debtor.find_by_employee_id_number(record.fetch(:employer_id_number))
      puts "Searching db by EIN"
      debtor = Debtor.find_by_employee_id_number(record.fetch(:employer_id_number))
    when record[:debtor_name] && !record.fetch(:debtor_name).strip.downcase['null']
      puts "NAME SEARCH for #{record[:debtor_name]}"
      debtor = Debtor.find_by_name(record.fetch(:debtor_name))
    else 
      debtor = nil
    end
    debtor.blank? ? false : debtor.id
  end
end



  # def self.check_utf_encoding(file)
  #   require 'cmess/guess_encoding'
  #   input = File.read(file)
  #   CMess::GuessEncoding::Automatic.guess(input)
  # end
    
  # def self.sanitize_row(record)
  #   ## Iterate over each value and strip any Dangerous SQL
  #   ## hash :key sanitation happens w/ a merge later on
  #   cleaned_record = {}
  #   record.each_pair do |k,v| #this might remove too much info...
  #     cleaned_record.store(k,
  #       v.to_s.gsub(/\//i, '-').gsub(/[^ [:word:]\-\. ]/i, '') )
  #       # first exchanges \ for - then removes everything not[^ ] :word or - or . or space
  #       # put sql problem chars here only.gsub(/\W+/, ""))
  #   end
  #   cleaned_record
  # end
  
  # def self.blank_out_fields(record, fields)
  #   # blank out fields if record[field] is nil
  #   fields.to_a.each do |field|
  #     if record[field.to_sym].nil?
  #       record[field.to_sym] = ''
  #     end
  #   end
  #   record
  # end
  
  # def self.add_missing_keys(hash_record, keys_array=[], default_value=nil)
  #   # remember merge is a one-way operation <=
  #   Hash[keys_array.map{|k| [ k, default_value ] }].merge(hash_record)
  # end

