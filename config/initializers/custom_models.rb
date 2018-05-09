Rails.application.config.to_prepare do
  CamaleonCms::Site.class_eval do
    include Plugins::FlexxPluginCrm::Concerns::HasContacts
    include Plugins::FlexxPluginCrm::Concerns::HasTasks

    has_many :task_recipes, class_name: 'Plugins::FlexxPluginCrm::TaskRecipe'
    has_many :automated_campaigns, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaign'
    has_many :automated_campaign_jobs, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignJob'
  end

  Plugins::CamaContactForm::CamaContactForm.class_eval do
    has_many :task_recipe_to_contact_form_associations, class_name: 'Plugins::FlexxPluginCrm::TaskRecipeToContactFormAssociation'
    has_many :task_recipes, class_name: 'Plugins::FlexxPluginCrm::TaskRecipe', through: :task_recipe_to_contact_form_associations

    has_many :automated_campaign_to_contact_form_associations, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignToContactFormAssociation'
    has_many :automated_campaigns, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaign', through: :automated_campaign_to_contact_form_associations
  end
end
