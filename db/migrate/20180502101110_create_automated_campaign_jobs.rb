class CreateAutomatedCampaignJobs < ActiveRecord::Migration
  def change
    create_table :automated_campaign_jobs do |t|
      t.integer :site_id, null: false
      t.integer :automated_campaign_id, null: false
      t.integer :automated_campaign_step_id, null: false
      t.integer :contact_id, null: false
      t.string :status, null: false
      t.string :send_to, null: false
      t.datetime :send_at, null: false
      t.text :message, null: false
      t.datetime :status_changed_at, null: false

      t.timestamps null: false
    end
  end
end
