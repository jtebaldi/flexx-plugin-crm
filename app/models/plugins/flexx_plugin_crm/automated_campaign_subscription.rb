require 'aasm'

class Plugins::FlexxPluginCrm::AutomatedCampaignSubscription < ActiveRecord::Base
  include AASM

  self.table_name = 'automated_campaign_subscriptions'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :campaign, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaign'

  has_many :steps, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignSubscriptionStep'

  aasm do
    state :running, initial: true
    state :paused, :finished, :deleted
  end
end
