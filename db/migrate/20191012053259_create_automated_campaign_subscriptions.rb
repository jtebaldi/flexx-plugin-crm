class CreateAutomatedCampaignSubscriptions < ActiveRecord::Migration
  def change
    create_table :automated_campaign_subscriptions do |t|
      t.integer :contact_id, null: false, index: true
      t.integer :automated_campaign_id, null: false, index: true
      t.string :aasm_state, null: false, index: true
      t.integer :created_by, null: false
      t.integer :next_step, null: false
    end
  end
end
