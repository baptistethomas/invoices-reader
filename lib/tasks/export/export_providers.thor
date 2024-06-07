# frozen_string_literal: true

require_relative '../../../config/environment'
require 'rubyXL'

class ExportProviders < Thor
  desc 'Export Providers', 'Export total weight distribution and carbon equivalencies, per provider from invoices infos'
  def process
    # Create workbook
    workbook = RubyXL::Workbook.new

    # Define headers columns and add it in data
    headers = ['total kg', 'categorized kg', 'uncategorized kg', 'with origin kg', 'without origin kg', 'with bio kg',
               'without bio kg', 'eqco2 kg total']

    # Create one worksheet per provider
    providers = Provider.all
    return unless providers.count.positive?

    # We choose to regroup data by provider/worksheet, so computes are done by provider
    providers.each do |provider|
      # Init header's values
      total_kg = 0
      categorized_kg = 0
      uncategorized_kg = 0
      with_origin_kg = 0
      without_origin_kg = 0
      with_bio_kg = 0
      without_bio_kg = 0
      eqco2_total = 0

      # Get Provider invoices
      invoices = Invoice.from_provider(provider['id'])

      # If the provider has invoices, we browse them
      if invoices&.count&.positive?
        invoices.each do |invoice|
          # If the invoice has invoice items, we browse them
          invoice_items = InvoiceItem.from_invoice(invoice['id'])
          next unless invoice_items&.count&.positive?

          invoice_items.each do |invoice_item|
            # We cumulate weight in the right places filtering origin, category and bio
            # Considering no weight info from invoice is worthless
            next if invoice_item['kilogram'].nil?

            # Categorized
            invoice_item['category'].nil? ? uncategorized_kg += invoice_item['kilogram'] : categorized_kg += invoice_item['kilogram']
            # Origin
            invoice_item['origin'].nil? ? without_origin_kg += invoice_item['kilogram'] : with_origin_kg += invoice_item['kilogram']
            # Bio
            invoice_item['bio'] == true ? with_bio_kg += invoice_item['kilogram'] : without_bio_kg += invoice_item['kilogram']
            # Calculate eqCo2 total
            eqco2_total += CarbonCalculator.get_eqco2_by_item_origin(invoice_item['origin'], invoice_item['kilogram'])
            # Calculate total kg and round it to 2 decimals
            total_kg += invoice_item['kilogram']
          end
        end
      end

      # Adding provider row data
      provider_data_ = [total_kg, categorized_kg, uncategorized_kg, with_origin_kg, without_origin_kg, with_bio_kg,
                        without_bio_kg, eqco2_total]

      # Using the first names value as worksheet's name
      worksheet = workbook.add_worksheet(provider.names[0])

      # Browse headers and write columns accordingly
      headers.each_with_index do |header_data, column_index|
        worksheet.add_cell(0, column_index, header_data)
      end

      # Browse provider data and write columns accordingly
      provider_data_.each_with_index do |header_data, column_index|
        worksheet.add_cell(1, column_index, header_data)
      end
    end

    # Clean default created Sheet1 worksheet
    workbook.worksheets.delete(workbook['Sheet1']) if workbook[0].sheet_name == 'Sheet1'

    # Write the xlsx file at the right place
    workbook.write('db/data/export/export_providers.xlsx')
  end
end
