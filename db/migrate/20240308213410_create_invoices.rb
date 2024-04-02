class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.integer :provider_id, null: false
      t.timestamps
    end
    add_foreign_key :invoices, :providers, column: :provider_id
    add_index :invoices, :provider_id
  end
end
