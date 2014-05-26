class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable :rememberable,
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable
         
  # has_one :user_role #, -> {readonly}    
end
