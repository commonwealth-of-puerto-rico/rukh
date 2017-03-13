# -*- encoding : utf-8 -*-
## External GEMs
require 'cmess/guess_encoding' 

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
  
  ## When called on a block from an opened file returns the number of lines 
  ##
  def find_number_lines(opened_file)
      start_time       = Time.now
    total_file_lines = opened_file.each_line.inject(0){|total, _amount| total + 1} 
    opened_file.rewind
    if Rails.env.development?
      end_time         = Time.now
      puts("1. Lines ==> #{total_file_lines} in #{((end_time - start_time) / 60).round(2)}")
    end
    total_file_lines
  end 
  
  ## To clean up a hash with only permited keys
  def delete_all_keys_except(hash_record, 
      except_array= [])
    hash_record.select do |key|
      except_array.include?(key)
    end
  end
  
end