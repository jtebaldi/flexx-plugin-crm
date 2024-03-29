class Plugins::FlexxPluginCrm::AutomatedCampaignStep < ActiveRecord::Base
  self.table_name = 'automated_campaign_steps'

  belongs_to :automated_campaign, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaign'

  scope :active, -> { where(enabled: true) }
end
