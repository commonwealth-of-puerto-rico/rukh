require 'prawn'

module PDF
  def generate_pdf(content)
    pdf = Prawn::Document.new
    pdf.text content
    pdf
  end
end 

### Problem:
=begin
Need to generate pdf before mailer is generate so I can attach it.
=end