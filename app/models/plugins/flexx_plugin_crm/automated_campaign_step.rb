class Plugins::FlexxPluginCrm::AutomatedCampaignStep < ActiveRecord::Base
  self.table_name = 'automated_campaign_steps'

  belongs_to :automated_campaign, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaign'
  belongs_to :stock, class_name: 'Plugins::FlexxPluginCrm::Stock'

  scope :active, -> { where(enabled: true) }

  def distance_of_time_from_now
    if self.due_on_value > 0
      distance_of_time_in_words(Time.now, Time.now + self.due_on_value.send(self.due_on_unit))
    else
      'immediately'
    end
  end
end
