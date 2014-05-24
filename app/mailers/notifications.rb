class Notifications < ActionMailer::Base
  default from: "from@example.com"
  before_action :add_inline_logo!
  
  def first_notification(recipient)
    attachments['something.txt'] = File.read('spec/factories/sample_email.pdf.txt')
    @debtor = Debtor.first #TODO fix this
    @debt = Debt.first  #TODO fix this
    mail(to: recipient.email, bcc: "watcher@example.com") #do |format|
     # format.txt
      #format.html #TODO register txt as a mime type
      #end
  end
  
  def second_notification(recipient)
    mail(to: recipient.email, bcc: "watcher@example.com") do |format|
      format.html
    end
  end
  
  private
  def add_inline_logo!
    attachments.inline['logo.png'] = File.read("app/assets/images/57.png")
  end
    
end


# <%= image_tag attachments['photo.png'].url -%>

# Make sure not to put a leading '/' on the File paths33