require 'aasm'

class Plugins::FlexxPluginCrm::AutomatedCampaignSubscriptionStep < ActiveRecord::Base
  include AASM

  self.table_name = 'automated_campaign_subscription_steps'

  belongs_to :subscription, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignSubscription'
  belongs_to :campaign_step, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignStep'

  aasm do
    state :scheduled, initial: true
    state :done, :deleted
  end
end
