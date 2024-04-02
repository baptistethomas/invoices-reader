class CreateInvoiceItems < ActiveRecord::Migration[7.1]
  def change
    create_table :invoice_items do |t|
      t.integer :invoice_id, null: false
      t.string :name, null: false
      t.boolean :agribalyse, default: false
      t.string :category, default: nil
      t.string :subcategory, default: nil
      t.string :origin, default: nil
      t.boolean :bio, default: false
      t.float :kilogram
      t.timestamps
    end
    add_foreign_key :invoice_items, :invoices, column: :invoice_id
    add_index :invoice_items, :invoice_id
  end
end
