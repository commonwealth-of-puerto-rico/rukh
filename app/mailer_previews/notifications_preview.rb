class NotificationsPreview
  
  def primera_notificacion
    Notifications.first_notification mock_user('Ciudadano','ciudadano@example.com')
  end


  def segunda_notificacion
    Notifications.second_notification mock_user('Ciudadano', 'ciudadano@example.com')
  end
  
  def modelo_SC_724
    Notifications.modeloSC_724(params[:debt_id])
  end
  
  private
  # How the hell am I going to fix this...
  def mock_user(name, email)
    st = Struct.new(:name, :email)
    mock = st.new(name, email)
    mock
  end
  
end
