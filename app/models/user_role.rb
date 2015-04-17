# -*- encoding : utf-8 -*-
class UserRole < ActiveRecord::Base
  has_many :users
end
