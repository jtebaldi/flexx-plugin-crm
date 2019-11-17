class Plugins::FlexxPluginCrm::AutomatedCampaignStep < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  self.table_name = 'automated_campaign_steps'

  belongs_to :automated_campaign, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaign'
  belongs_to :stock, class_name: 'Plugins::FlexxPluginCrm::Stock'

  has_many :subscription_steps, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignSubscriptionStep'

  scope :active, -> { where(enabled: true) }

  before_validation :set_defaults

  after_update :update_running_campaigns, if: Proc.new { |cs| cs.due_on_value_changed? }

  def distance_of_time_from_now
    if self.due_on_value > 0
      distance_of_time_in_words(Time.now, Time.now + self.due_on_value.send(self.due_on_unit))
    else
      'immediately'
    end
  end

  private

  def set_defaults
    self.due_on_value = 0 if due_on_value.nil?
    self.due_on_unit = 'minutes' if due_on_unit.nil?
  end

  def update_running_campaigns
    self.automated_campaign.subscriptions.not_ended.
      includes(:next_step).
      where(automated_campaign_subscription_steps: { aasm_state: :scheduled }).
      references(:automated_campaign_subscription_steps).each do |s|
      next_step_due_on = s.next_step.campaign_step.due_on_value.send(s.next_step.campaign_step.due_on_unit).to_i

      if (s.next_step.created_at + self.due_on_value.send(self.due_on_unit)) - s.next_step.send_at > 0
        step = s.steps.find_by(automated_campaign_step_id: self.id)
        step.update(send_at: step.created_at + self.due_on_value.send(self.due_on_unit))
      end
    end
  end
end
