class NotificationsMailerPreview
  def primera_notificacion
    NotificationsMailer.first(Debt.first, User.first) 
  end
  
  
  def segunda_notificacion
    NotificationsMailer.second 
  end


  def tercera_notificacion
    NotificationsMailer.third 
  end

  private
    def mock_user(name, email)
      st = Struct.new(:name, :email)
      mock = st.new(name, email)
      mock
    end
  
end
