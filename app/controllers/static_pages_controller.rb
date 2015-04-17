# -*- encoding : utf-8 -*-
class StaticPagesController < ApplicationController
  def home
    
  end
  
  def help
    
  end
  
  def dev
    @user = current_user
  end
  
  def prifas_account
    respond_to :json
  end

end
