require_relative "../../../config/environment"
require 'rubyXL'

class ImportInvoices < Thor

  desc "Import Invoices", "Import Invoices to database from an invoices JSON File"
  def process
    # Define OCR & Agribalyse path
    ocr_path = './././db/data/import/ocr_payload.json'
    agribalyse_path = './././db/data/import/AGRIBALYSE3.1.1_produits alimentaires.xlsx'

    # Read agribalyse DB and keep Synthesis Worksheet only
    # Looks like the only one that we need
    workbook = RubyXL::Parser.parse agribalyse_path
    worksheets = workbook.worksheets
    worksheet_synthesis = worksheets[1]

    # Read & parse OCR file
    data_ocr = File.read(ocr_path)
    rows_ocr = JSON.parse(data_ocr)

    # Browse OCR result
    rows_ocr.each do |row_ocr|
      # Considering that processing the data without a provider from file is worthless
      unless row_ocr['vendor_name'].empty?
        # Check if we have the provider in the DB to flag invoice accordingly
        existing_provider = Provider.get_provider_by_one_of_names(StringManipulation.remove_accents(row_ocr['vendor_name']))
        # Considering that invoice without provider match in DB is worthless
        # TO DO : Maybe create provider not found in DB, but need to refine get_provider_by_one_of_names accordingly to prevent duplicates
        if existing_provider
          # Create Invoice
          invoice = Invoice.create_invoice(existing_provider)
          if invoice
            # Invoice created successfully, creating the items corresponding to the invoice
            Invoice.create_invoice_items(invoice, row_ocr['items'], worksheet_synthesis)
          end
        end
      end
    end
  end

end