require 'aasm'

class Plugins::FlexxPluginCrm::AutomatedCampaignSubscription < ActiveRecord::Base
  include AASM

  self.table_name = 'automated_campaign_subscriptions'

  after_update :delete_steps, if: proc { |s| s.deleted? }

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :campaign, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaign', foreign_key: :automated_campaign_id

  has_many :steps, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignSubscriptionStep', dependent: :destroy

  scope :running, -> { where(aasm_state: :running) }
  scope :ended, -> { where(aasm_state: [:finished, :unsubscribed]) }

  aasm do
    state :running, initial: true
    state :paused, :finished, :deleted, :unsubscribed
  end

  def ordered_steps
    steps.sort_by { |row| row.due_on_value.send(row.due_on_unit).to_i }
  end

  def ordered_scheduled_steps
    steps.scheduleds.order(:send_at)
  end

  private

  def delete_steps
    self.steps.each do |step|
      step.update!(
        aasm_state: :deleted,
        deleted_by: self.deleted_by,
        deleted_at: self.deleted_at
      ) if step.scheduled?
    end
  end
end
