require 'aasm'

class Plugins::FlexxPluginCrm::AutomatedCampaignSubscription < ActiveRecord::Base
  include AASM

  self.table_name = 'automated_campaign_subscriptions'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :campaign, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaign', foreign_key: :automated_campaign_id

  has_many :steps, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignSubscriptionStep', dependent: :destroy

  scope :running, -> { where(aasm_state: :running) }

  aasm do
    state :running, initial: true
    state :paused, :finished, :deleted
  end

  def ordered_steps
    steps.sort_by { |row| row.due_on_value.send(row.due_on_unit).to_i }
  end

  def ordered_scheduled_steps
    steps.scheduleds.order(:send_at)
  end
end
