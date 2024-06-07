# frozen_string_literal: true

class Invoice < ApplicationRecord
  has_many :invoice_items, dependent: :destroy

  # DB METHODS
  scope :from_provider, ->(provider_id) { where(provider_id:) }

  # CLASSIC METHODS
  # Create Invoice for a provider
  def self.create_invoice(provider)
    create(provider_id: provider['id']) if provider.present?
  end

  # Create Items for an invoice
  def self.create_invoice_items(invoice, items_list, synthesis)
    items_list.each do |row_item|
      next if row_item['item_description'].blank?

      invoice_item = invoice.invoice_items.new(
        name: row_item['item_description'],
        kilogram: row_item['item_quantity']
      )

      invoice_item.bio = invoice_item.bio?(row_item['item_description'])
      invoice_item.origin = invoice_item.origin?(row_item['item_description'])

      agribalyse_infos_json = invoice_item.agribalyse(row_item['item_description'], synthesis)
      agribalyse_infos = JSON.parse(agribalyse_infos_json)

      if agribalyse_infos.present?
        invoice_item.assign_attributes(
          agribalyse: agribalyse_infos['agribalyse_reference'],
          category: agribalyse_infos['agribalyse_category'],
          subcategory: agribalyse_infos['agribalyse_subcategory']
        )
      else
        invoice_item.assign_attributes(
          agribalyse: false,
          category: nil,
          subcategory: nil
        )
      end

      invoice_item.save if invoice_item.valid?
    end
  end
end