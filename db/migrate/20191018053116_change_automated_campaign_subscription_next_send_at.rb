class ChangeAutomatedCampaignSubscriptionNextSendAt < ActiveRecord::Migration
  def change
    change_column_null :automated_campaign_subscriptions, :next_send_at, true
  end
end
