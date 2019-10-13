class ChangeAutomatedCampaignSubscription < ActiveRecord::Migration
  def change
    change_column_null :automated_campaign_subscriptions, :created_by, true
    change_column_null :automated_campaign_subscriptions, :next_step, true
  end
end
