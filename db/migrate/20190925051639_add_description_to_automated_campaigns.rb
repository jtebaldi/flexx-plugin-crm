class AddDescriptionToAutomatedCampaigns < ActiveRecord::Migration
  def change
    add_column :automated_campaigns, :description, :string
  end
end
