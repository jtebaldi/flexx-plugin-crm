class ChangeAutomatedCampaignStepsDueOnValueDefault < ActiveRecord::Migration
  def change
    change_column_default :automated_campaign_steps, :due_on_value, 0
  end
end
