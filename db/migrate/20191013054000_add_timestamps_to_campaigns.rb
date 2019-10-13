class AddTimestampsToCampaigns < ActiveRecord::Migration
  def change
    add_timestamps(:automated_campaign_subscriptions)
    add_timestamps(:automated_campaign_subscription_steps)

    add_column :automated_campaign_subscription_steps, :send_at, :datetime, null: false
  end
end
