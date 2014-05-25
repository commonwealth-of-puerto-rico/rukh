class Debt < ActiveRecord::Base
  
  ## Hooks
  belongs_to :debtor, touch: true
  #has_many :payment_plans
  
  ## REGEX
  VALID_PERMIT_NUM_REGEX = //
  VALID_INFRACTION_NUM_REGEX = //
  VALID_NUM_REGEX = /\A[[:digit:]]+\.?[[:digit:]]*\z/
  
  
  ## Validations
  # validates :transaction_contact_person, length: {maximum: 144}
  validates :debtor_id, presence: true
  validates :amount_owed_pending_balance, format: { with: VALID_NUM_REGEX, 
            message: "Debe ser un número."}
  validates :bounced_check_number, format: { with: /\A[[:digit:]]*\z/i, 
            message: "Debe ser un número."}
  
  
  ## Methods
  def find_debtor_name(debtor_id)
    debtor = Debtor.find_by_id(debtor_id)
    debtor.nil? ? 'NULL' : debtor.name
  end
   
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names + [:debtor_name]
      all.each do |debt_record|
        debtor_name = debt_record.find_debtor_name(debt_record.attributes["debtor_id"])
        csv << (debt_record.attributes.values_at(*column_names) << debtor_name)
      end
    end
  end

  private
    def self.to_plain_csv(options = {}) #For portability of code only.
      CSV.generate(options) do |csv|
        csv << column_names
        all.each do |debt_record|
          csv << debt_record.attributes.values_at(*column_names)
        end
      end
    end
  
end
