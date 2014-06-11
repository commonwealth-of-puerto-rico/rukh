class EmailsController < ApplicationController
  before_action :authenticate_user! ## for DEVISE
  
  def index
    puts ActionMailer::Base.preview_path.inspect
    @previews = []
    
  end
  
  def edit
  end
  
  def update
  end
  
  def send
    #This can later use params to drive it out.
    Notifications.first_notification(current_user).deliver
    #redirect back?
  end
  
  
end
