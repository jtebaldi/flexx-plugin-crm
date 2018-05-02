class CreateAutomatedCampaignSteps < ActiveRecord::Migration
  def change
    create_table :automated_campaign_steps do |t|
      t.integer :automated_campaign_id, null: false
      t.integer :created_by, null: false
      t.string :name, null: false
      t.integer :due_on_value, null: false
      t.string :due_on_unit, null: false
      t.text :message, null: false
      t.boolean :enabled, default: true
      t.integer :disable_by
      t.datetime :disabled_at

      t.timestamps null: false
    end
  end
end
