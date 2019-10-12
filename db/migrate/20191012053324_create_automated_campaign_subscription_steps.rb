class CreateAutomatedCampaignSubscriptionSteps < ActiveRecord::Migration
  def change
    create_table :automated_campaign_subscription_steps do |t|
      t.integer :automated_campaign_subscription_id, index: { name: 'automated_campaign_subscription_id_index' }, null: false
      t.integer :automated_campaign_step_id, index: { name: 'automated_campaign_step_id_index' }, null: false
      t.string :aasm_state, null: false, index: true
      t.datetime :completed_at
    end
  end
end
