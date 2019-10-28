class AddDeletedByToAutomatedCampaignSubscriptions < ActiveRecord::Migration
  def change
    add_column :automated_campaign_subscriptions, :deleted_by, :integer
    add_column :automated_campaign_subscriptions, :deleted_at, :datetime
    add_column :automated_campaign_subscription_steps, :deleted_by, :integer
    add_column :automated_campaign_subscription_steps, :deleted_at, :datetime
  end
end
