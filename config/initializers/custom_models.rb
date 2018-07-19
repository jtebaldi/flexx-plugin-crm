Rails.application.config.to_prepare do
  CamaleonCms::Site.class_eval do
    include Plugins::FlexxPluginCrm::Concerns::HasContacts
    include Plugins::FlexxPluginCrm::Concerns::HasTasks

    acts_as_tagger

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

  user_class = (PluginRoutes.static_system_info['user_model'].presence || 'CamaleonCms::User').constantize

  user_class.class_eval do
    def initials
      result = if first_name.present? && last_name.present?
        "#{first_name[0]}#{last_name[0]}"
      else
        "#{username[0]}#{username[1]}"
      end

      result.upcase
    end

    def print_name
      result = [first_name, last_name].join(' ')
      result.blank? ? username : result
    end
  end
end
