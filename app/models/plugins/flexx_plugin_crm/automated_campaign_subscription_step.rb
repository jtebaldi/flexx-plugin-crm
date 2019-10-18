require 'aasm'

class Plugins::FlexxPluginCrm::AutomatedCampaignSubscriptionStep < ActiveRecord::Base
  include AASM

  self.table_name = 'automated_campaign_subscription_steps'

  after_save :update_subscription_next_step

  belongs_to :subscription, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignSubscription', foreign_key: :automated_campaign_subscription_id
  belongs_to :campaign_step, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignStep'

  scope :scheduleds, -> { where(aasm_state: :scheduled) }

  aasm do
    state :scheduled, initial: true
    state :done, :deleted
  end

  private

  def update_subscription_next_step
    byebug
    AutomatedCampaignService.update_next_step(subscription: self.subscription)
  end
end
