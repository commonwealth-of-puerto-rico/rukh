# -*- encoding : utf-8 -*-
class StaticPagesController < ApplicationController
  
  ## Resource Actions ##
  def home
    
  end
  
  def help
    
  end
  
  def dev
    @user = current_user
  end
  
  ## Stub for integration with other systems
  #TODO implement
  def prifas_account
    respond_to :json
  end

end
