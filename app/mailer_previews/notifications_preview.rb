class NotificationsPreview
  
  def first_notification
    Notifications.first_notification mock_user('Ciudadano','ciudadano@example.com')
  end


  def second_notification
    Notifications.second_notification mock_user('Ciudadano', 'ciudadano@example.com')
  end
  
  private
  # How the hell am I going to fix this...
  def mock_user(name, email)
    st = Struct.new(:name, :email)
    mock = st.new(name, email)
    mock
  end
  
end
