class CreateAutomatedCampaignToContactFormAssociations < ActiveRecord::Migration
  def change
    create_table :automated_campaign_to_contact_form_associations do |t|
      t.integer :automated_campaign_id
      t.integer :cama_contact_form_id

      t.timestamps null: false
    end
  end
end
