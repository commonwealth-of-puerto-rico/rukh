class StaticPagesController < ApplicationController
  def home
    
  end
  
  def help
    
  end
  
  def dev
    render layout: false
  end

end
