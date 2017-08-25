module ImportSupport2
  def self.debt_headers_array
    %i[
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
  end

  def self.debtor_headers_array
    %i[id employer_id_number name tel email address location contact_person]
  end

  ## To clean up a hash with only permited keys
  def self.delete_all_keys_except(hash_record, except_array = [])
    hash_record.select do |key|
      except_array.include?(key)
    end
  end
end