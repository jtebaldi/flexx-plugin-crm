class Plugins::FlexxPluginCrm::AutomatedCampaign < ActiveRecord::Base
  self.table_name = 'automated_campaigns'

  has_many :automated_campaign_to_contact_form_associations, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignToContactFormAssociation'
  has_many :cama_contact_forms, class_name: 'Plugins::CamaContactForm::CamaContactForm', through: :automated_campaign_to_contact_form_associations
  has_many :steps, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignStep'

  scope :active, -> { where(archived: false) }

  def ordered_steps
    steps.sort_by { |row| row.due_on_value.send(row.due_on_unit).to_i }
  end
end
