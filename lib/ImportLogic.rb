# -*- encoding : utf-8 -*-

## External GEMs
require 'smarter_csv'
require 'celluloid/current'
require 'thread'

## Internal Libraries
require 'ImportSupport'

# TODO: it's done half way due to change requirements

## This method is an actor whose purpose is to querry the actor doing the updating
## and update the progress bar on the UI. I am thinking of using SSE events to do the
## updating.
class ProgressBarUpdater
  include Celluloid
  def initialize
    # socket?
    @status = 0
  end

  def run(actor)
    # stub
    puts 'UPDATER!!?'
    puts actor.current_progress
    @status = actor.current_progress
  end

  def on_change
    yield @status # I don't know how to implement this sans callback
  end
end

# Import should initiallize an actor obj that gets sent the file name to import
# as a msg. One actor per import patern allowing multiple ones.
# There should be an import mutex lock since
# only one import job should be done at a time.
class ImportLogic
  include Celluloid
  include ImportSupport

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

  attr_reader :exit_status, :result

  def initialize(updater_actor)
    @updater_actor = updater_actor
    @counter = []
    @total_lines = 0
    @exit_status = 1
    @result = {}
  end

  def import_in_progress?
    # Check Mutex mutex.try_lock
    false
  end

  def current_progress
    puts @counter.inspect
  end

  def import_csv(file)
    unless import_in_progress?
      file_lines   = find_file_lines(file)
      @total_lines = file_lines
      char_set     = check_utf_encoding(File.read(file.tempfile))
      process_CSV_file(file.tempfile, file_lines, char_set)
    end
  end

  private

  ## Calls ImportSuportModule function with opened file.
  def find_file_lines(file)
    file.open { |f| find_number_lines(f) }
  end

  ## Main import method. Uses an active record transaction (if it fails the whole thing
  ## is rolled back) to prevent partial importing
  def process_CSV_file(file, _total_lines = 0, charset = 'bom|utf-8')
    start_time = Time.now.to_i # setting up time keeping
    ActiveRecord::Base.transaction do
      SmarterCSV.process(file, chunk_size: 10, verbose: true, file_encoding: charset.to_s) do |file_chunk|
        file_chunk.each do |record_row|
          sanitized_row = sanitize_row(record_row)
          process_record_row(sanitized_row, {})
          @counter << sanitized_row # appends in latest record to allow error to report where import failed
          ### CallingActorInUpdater feeding it the this (the current) actor.
          @updater_actor.run(Celluloid::Actor.current) unless @updater_actor.nil?
          @counter
        end
      end
      # finishing up time keeping and reporting:
      total_count = @counter.size
      end_time = Time.now.to_i
      total_count_hash = { total_lines: total_count, time: ((end_time - start_time) / 60).round(2) }
      puts "\033[32m#{total_count_hash}\033[0m\n" # green
      @exit_status = 0
      @result = total_count_hash
    end
  ensure
    # on CSV::MalformedCSVError # something gets said
    @updater_actor.terminate unless @updater_actor.nil?
  end

  def process_record_row(record, _options = {})
    debtor_id = debtor_in_db_already(record)
    debt_id = record.fetch(:id, 0).to_i

    if debtor_id
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
        raise "Can't Update Record without matching IDs"
      end
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

  def store_debt_record(record, debt_array = @@debt_headers_array)
    store_one_record(record, debt_array, Debt)
  end

  def update_debt_record(record, id, debt_array = @@debt_headers_array)
    store_one_record(record, debt_array, Debt, update: true, id: id, debt: true)
  end

  def update_debtor_record(record, debtor_id, debtor_array = @@debtor_headers_array)
    store_one_record(record, debtor_array, Debtor,
                     update: true, id: debtor_id, debtor: true) { |debtor_record| debtor_record[:contact_person] = debtor_record[:name] }
  end

  def store_debtor_record(record, debtor_array = @@debtor_headers_array)
    store_one_record(record, debtor_array,
                     Debtor) { |debtor_record| debtor_record[:contact_person] = debtor_record[:name] }
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
end
