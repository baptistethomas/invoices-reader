require_relative "../../../config/environment"
require 'json'

class ImportProviders < Thor
  desc "Import Providers", "Import Providers to database from a providers JSON File"
  def process
    # Read & parse providers
    file_path = './././db/data/import/providers.json'
    data = File.read(file_path)
    rows = JSON.parse(data)

    # Browse them and instance object accordingly
    rows.each do |row|
      provider = Provider.new(
        names: row['names'],
        vat_numbers: row['vat_numbers'],
        organic: row['organic'],
        exclusive_item_kind: row['exclusive_item_kind']
      )

      # Save them in DB if they are valid
      if provider.valid?
        provider.save
      end
    end
  end
end