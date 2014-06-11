class NotificationsMailerPreview
  
  def primera_notificacion
    NotificationsMailer.first(Debt.first, mock_user(:mock, 'mock@example.com')) 
  end
  
  
  def segunda_notificacion
    NotificationsMailer.second(Debt.first, mock_user(:mock, 'mock@example.com')) 
  end


  def tercera_notificacion
    NotificationsMailer.third(Debt.first, mock_user(:mock, 'mock@example.com')) 
  end

  private
    def mock_user(name, email)
      st = Struct.new(:name, :email)
      mock = st.new(name, email)
      mock
    end
  
end
