require 'HexString'
class Debtor < ActiveRecord::Base
  
  has_many :debts, dependent: :restrict_with_exception 
  # :restrict #or :restrict_with_error 

  
  ## Hooks
  before_save {self.email = email.downcase}
  before_save {self.ss_last_four = last_four(ss_hex_digest) unless ss_hex_digest.blank?}
  before_save {self.uses_personal_ss = true unless ss_hex_digest.blank?}
  before_save {self.contact_person_email = email.downcase}
  before_save do
    unless self.ss_hex_digest.blank?
      self.ss_hex_digest = Debtor.encrypt(ss_hex_digest)
    else
      self.ss_hex_digest = nil #'NULL'
    end
  end
  #TODO before save clean up telephone number and ss
  # before_save record_transaction
  
  ## REGEX
  VALID_EMAIL_REGEX = /\A(\z|[\w+\-.]+@[a-z\d\-.]+\.[a-z]+)\z/i
  VALID_TEL_REGEX = /\A(\z|([0-9]{3}-?[0-9]{3}-?[0-9]{4}))\z/
  VALID_EIN_REGEX = /\A(\z|([0-9]{2})-?([0-9]{7}))\z/ 
  VALID_SS_REGEX = /\A(\z|([0-9]{3}-?[0-9]{2}-?[0-9]{4}))\z/
  VALID_DATE_REGEX = // 

  
  ## Validations
  validates :name,                presence: true
  validates :contact_person,      presence: true
  validates :email,                format: { with: VALID_EMAIL_REGEX,
    message: "Email invalido"  }
  validates :contact_person_email, format: { with: VALID_EMAIL_REGEX,
    message: "Email invalido"  }  
  validates :employer_id_number, absence: true, 
    unless: Proc.new { |debtor_ex| debtor_ex.ss_hex_digest.blank? }
  validates :ss_hex_digest, absence: true, 
    unless: Proc.new { |debtor_ex| debtor_ex.employer_id_number.blank? }
  validates :employer_id_number,  uniqueness: true, 
    unless: Proc.new { |debtor_ex| debtor_ex.employer_id_number.blank? }
  validates :ss_hex_digest,       uniqueness: true, 
    unless: Proc.new { |debtor_ex| debtor_ex.ss_hex_digest.blank?  }
  validates :tel, format: { with: VALID_TEL_REGEX, 
    message: "Debe de der un número de teléfono válido: 'xxx-xxx-xxx'" }
  validates :employer_id_number,  format: { with: VALID_EIN_REGEX,
    message: "El Número de Seguro Social Patronal debe de ser válido: 'xx-xxxxxxx' o en blanco." }
  validates :ss_hex_digest,       format: { with: VALID_SS_REGEX,
    message: "El Número de Seguro Social Personal debe de ser válido: 'xx-xxx-xxxx' o en blanco." }
      
      
  ## Methods
  def self.search(search_term)
    search_term = clean_up_search_term(search_term)
    term_class = search_term.class
    case
    when term_class == Fixnum
      result = where('employer_id_number LIKE ?', "%#{search_term}%")
    when term_class == HexString #For API 
      result = where('ss_hex_digest LIKE ?', "%#{search_term}%")
    when term_class == String
      result = where('LOWER(name) LIKE ? OR employer_id_number LIKE ? OR email LIKE ?', 
                     "%#{search_term}%", "%#{search_term}%", "%#{search_term}%")
    else
      fail "search term of unknown type (find me in debtor model)"
    end
  end
  
  # def self.api_search(search_term)
  #   #reject format xxx-xx-xxxx 
  #   #accecpt only string or xx-xxxxxxxx
  #   Debtor.search(search_term)
  # end
  
  def self.clean_up_search_term(search_term) 
    #if name keep string, if ein turn to int, if ss turn to hexstring else string
    #'-' is checked.
    case search_term
    when /\A([[:digit:]]{3}-[[:digit:]]{2}-[[:digit:]]{4})\z/
      HexString.new(Debtor.encrypt(search_term)) #or Encrypt(search_term)
    when /\A([0-9]{2}-[0-9]{7})\z/  #REGEX for EIN
      Debtor.remove_hyphens(search_term).to_i
    when /\A[[:xdigit:]]+\z/i
      HexString.new search_term.to_s.downcase
    else
      search_term.to_s.downcase
    end
  end
  
  private
  def last_four(ss_num)
    Debtor.remove_hyphens(ss_num).split('')[-4..-1].join('')
  end
  def Debtor.remove_hyphens(term)
    term.to_s.each_char.select{|x| x.match /[0-9]/}.join('')
  end
  def Debtor.encrypt(token)
    Digest::SHA1.hexdigest(Debtor.salt(Debtor.remove_hyphens token ).to_s)
  end
  def Debtor.salt(token, salt=Rails.application.secrets.salt) #salt stored in secrets.yml
    token.to_i + salt
  end
  # def check_for_debts
  #   #  before_destroy :check_for_debts
  #   if debts.count > 0
  #     errors.add_to_base("No se puede borrar Deudor con Deudas.")
  #     return false
  #   end
  # end
  
  
end
