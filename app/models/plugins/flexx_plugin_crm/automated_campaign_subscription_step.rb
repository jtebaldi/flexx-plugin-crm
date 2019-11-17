require 'aasm'

class Plugins::FlexxPluginCrm::AutomatedCampaignSubscriptionStep < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::ActivityFeed
  include AASM

  self.table_name = 'automated_campaign_subscription_steps'

  after_save :update_subscription_next_step

  belongs_to :subscription, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignSubscription', foreign_key: :automated_campaign_subscription_id
  belongs_to :campaign_step, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignStep', foreign_key: :automated_campaign_step_id

  scope :scheduleds, -> { where(aasm_state: :scheduled) }

  aasm do
    state :scheduled, initial: true
    state :done, :deleted
  end

  private

  def update_subscription_next_step
    AutomatedCampaignService.update_next_step(subscription: self.subscription)
  end

  def has_activity_record?
    self.done?
  end

  def activity_record_params
    {
      feed_name: 'contact',
      feed_id: self.subscription.contact_id,
      args: {
        actor: 'system',
        verb: 'done',
        object: "AutomatedCampaignSubscriptionStep:#{self.id}",
        labels: {
          action: 'sent',
          action_type: "Campaign message - #{self.campaign_step.name} - ",
          actor: 'System'
        }
      }
    }
  end
end
