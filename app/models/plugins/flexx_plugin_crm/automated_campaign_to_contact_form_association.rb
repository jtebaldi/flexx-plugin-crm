class Plugins::FlexxPluginCrm::AutomatedCampaignToContactFormAssociation < ActiveRecord::Base
  self.table_name = 'automated_campaign_to_contact_form_associations'

  belongs_to :cama_contact_form, class_name: 'Plugins::CamaContactForm::CamaContactForm'
  belongs_to :task_recipe, class_name: 'Plugins::FlexxPluginCrm::TaskRecipe'
end
