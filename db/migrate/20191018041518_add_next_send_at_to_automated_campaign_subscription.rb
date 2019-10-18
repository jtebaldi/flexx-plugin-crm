class AddNextSendAtToAutomatedCampaignSubscription < ActiveRecord::Migration
  def change
    add_column :automated_campaign_subscriptions, :next_send_at, :datetime, null: false, index: true
  end
end
