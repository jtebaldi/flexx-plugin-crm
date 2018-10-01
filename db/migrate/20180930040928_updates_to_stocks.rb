class UpdatesToStocks < ActiveRecord::Migration
  def change
    change_column :stocks, :label, :string, null: true
    add_column :stocks, :name, :string, null: false
  end
end
