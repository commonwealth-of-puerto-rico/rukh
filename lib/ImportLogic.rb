## External GEMs
require 'cmess/guess_encoding' 
require 'smarter_csv' 

#TODO it's done half way due to change requirements
#TODO postponed to do export

class ImportLogic
  def self.import_csv(file)
    char_set = check_utf_encoding(file.tempfile)
    file_lines = find_file_lines(file)
    result = process_CSV_file(file.tempfile, file_lines, char_set)
  end
  
  def self.check_utf_encoding(file)
    require 'cmess/guess_encoding'
    input = File.read(file)
    CMess::GuessEncoding::Automatic.guess(input)
  end
  
  def self.find_file_lines(file)
    start_time = Time.now
    total_file_lines = file.open.lines.inject(0){|total, amount| total += 1}
    file.open.rewind # To reset file.
    end_time = Time.now
    puts "Lines ==> #{total_file_lines} in #{((end_time - start_time) / 60).round(2)}"
    total_file_lines
  end 
  
  def self.process_CSV_file(file, total_lines = 0, charset="bom|utf-8")
    begin 
      start_time = Time.now
      counter = []
      ActiveRecord::Base.transaction do
        SmarterCSV.process(file, {:chunk_size => 10, verbose: true, file_encoding: "#{charset}" } ) do |file_chunk|
          file_chunk.each do |record_row|
            sanitized_row = sanitize_row(record_row)
            process_record_row(sanitized_row, {})
            counter << 1
          end
        end
        total_count = counter.size #progress_bar.read
        end_time = Time.now
        total_count_hash = { total_lines: total_count, time: ((end_time - start_time) / 60 ).round(2) }
        puts "\033[32m#{total_count_hash}\033[0m\n"
      end
    ensure
      # CSV::MalformedCSVError
      #something gets said
    end   
  end
  
  def self.sanitize_row(record)
    ## Iterate over each value and strip any Dangerous SQL 
    ## hash :key sanitation happens w/ a merge later on
    cleaned_record = {}
    record.each_pair do |k,v| #this might remove too much info...
      cleaned_record.store(k, 
        v.to_s.gsub(/\//i, '-').gsub(/[^[[:word:]]\-\.[[:blank:]]]/i, '') )  
        #put sql problem chars here only.gsub(/\W+/, ""))
    end
    cleaned_record
  end
  
  def self.process_record_row(record, options={})
    #Monster Method #TODO refactoring
    if debtor_in_db_already(record)
      # Updating record
    elsif record[:debtor_id] && 
        !record.fetch(:debtor_id).strip.downcase['null']
      #Then Create Debtor from Record
      #merge hash to add missing keys
      ## Blank out nil values to empty strings:
      ## Store Debtor
      ## Store Debt
    else
      fail "Can't understand import record: #{record}"
    end
    
  end
  
  def self.blank_out_fields(record, fields)
    fields.to_a.each do |field|
      record[field.to_sym] = '' if record[field.to_sym].nil?
    end
    record
  end
  
  # def self.add_missing_keys(hash_record, keys_array=[], default_value=nil)
  #   # remember merge is a one-way operation <=
  #   Hash[keys_array.map{|k| [ k, default_value ] }].merge(hash_record)
  # end
  
  def self.debtor_in_db_already(record, db_Debtor=Debtor)
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