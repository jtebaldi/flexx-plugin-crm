class AddStockToAutomatedCampaignStep < ActiveRecord::Migration
  def change
    add_column :automated_campaign_steps, :stock_id, :integer, null: false
    remove_column :automated_campaign_steps, :message, :text
  end
end
