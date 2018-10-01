class AddStarredToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :starred, :boolean
  end
end
