class AddAutomatedCampaignIdToEmail < ActiveRecord::Migration
  def change
    add_column :emails, :automated_campaign_subscription_id, :integer, index: true
    add_column :emails, :automated_campaign_subscription_step_id, :integer, index: true
  end
end
