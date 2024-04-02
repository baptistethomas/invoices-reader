class CreateProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :providers do |t|
      t.text :names, array: true, default: []
      t.text :vat_numbers, array: true, default: []
      t.boolean :organic, default: false
      t.string :exclusive_item_kind, default: nil
      t.timestamps
    end
  end
end
