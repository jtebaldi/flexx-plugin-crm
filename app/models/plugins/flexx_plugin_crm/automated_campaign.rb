class Plugins::FlexxPluginCrm::AutomatedCampaign < ActiveRecord::Base
  self.table_name = 'automated_campaigns'

  has_many :steps, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignStep'

  scope :active, -> { where(archived: false) }

  def ordered_steps
    steps.sort_by { |row| row.due_on_value.send(row.due_on_unit).to_i }
  end
end
