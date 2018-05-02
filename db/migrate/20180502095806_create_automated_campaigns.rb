class CreateAutomatedCampaigns < ActiveRecord::Migration
  def change
    create_table :automated_campaigns do |t|
      t.integer :site_id, null: false
      t.string :name, null: false
      t.boolean :archived, default: false
      t.integer :archived_by
      t.datetime :archived_at
      t.boolean :paused, default: true
      t.integer :paused_by
      t.datetime :paused_at
      t.integer :created_by

      t.timestamps null: false
    end
  end
end
