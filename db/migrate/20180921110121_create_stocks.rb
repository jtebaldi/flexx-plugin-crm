class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.integer :site_id, index: true
      t.string :stock_type, null: false, index: true
      t.string :label, null: false, index: true
      t.string :description
      t.text :contents, null: false
      t.json :metadata, default: {}

      t.integer :created_by
      t.integer :updated_by

      t.timestamps null: false
    end

    add_index :stocks, [:site_id, :label], unique: true
  end
end
