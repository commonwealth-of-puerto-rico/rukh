require 'prawn'

def generate_pdf(content)
  pdf = Prawn::Document.new
  pdf.text content
  pdf
end