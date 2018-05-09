class Plugins::FlexxPluginCrm::AutomatedCampaignStep < ActiveRecord::Base
  self.table_name = 'automated_campaign_steps'

  scope :active, -> { where(enabled: true) }
end
