class Invoice < ApplicationRecord
  has_many :invoice_item, dependent: :destroy

  # DB METHODS
  def self.get_invoices_from_provider(provider_id)
    where(provider_id: provider_id)
  end

  # CLASSIC METHODS
  # Create Invoice for a provider
  def self.create_invoice(provider)
    invoice = Invoice.new
    invoice.provider_id = provider['id']
    if invoice.valid?
      invoice.save
      invoice
    end
  end

  # Create Items for an invoice
  def self.create_invoice_items(invoice, items_list, synthesis)
    items_list.each do |row_item|
      # We skip the process if the invoice item doesn't have a name
      unless row_item['item_description'].empty?
        invoice_item = InvoiceItem.new
        invoice_item.invoice_id = invoice['id']
        # Keeping original item description to refine and review result over time
        invoice_item.name = row_item['item_description']
        # Try to get agribalyse infos for this product name
        agribalyse_infos_json = invoice_item.has_agribalyse_reference(row_item['item_description'], synthesis)
        agribalyse_infos = JSON.parse(agribalyse_infos_json)
        # If has_agribalyse_reference returned infos we use them
        if !agribalyse_infos.empty?
          invoice_item.agribalyse = agribalyse_infos['agribalyse_reference']
          invoice_item.category = agribalyse_infos['agribalyse_category']
          invoice_item.subcategory = agribalyse_infos['agribalyse_subcategory']
        # We use default values if has_agribalyse_reference returned nothing
        else
          invoice_item.agribalyse = false
          invoice_item.category = nil
          invoice_item.subcategory = nil
        end
        # Considering as readme said, quantity are kg
        invoice_item.kilogram = row_item['item_quantity']
        # Checking if bio keywords appears in item description, then flag accordingly
        invoice_item.bio = invoice_item.is_bio(row_item['item_description'])
        # Checking if origin keywords appears in item description, then flag accordingly
        invoice_item.origin = invoice_item.has_origin(row_item['item_description'])
        if invoice_item.valid?
          invoice_item.save
        end
      end
    end
  end
end