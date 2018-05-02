Rails.application.config.to_prepare do
  CamaleonCms::Site.class_eval do
    include Plugins::FlexxPluginCrm::Concerns::HasContacts
    include Plugins::FlexxPluginCrm::Concerns::HasTasks

    has_many :task_recipes, class_name: "Plugins::FlexxPluginCrm::TaskRecipe"
    has_many :automated_campaigns, class_name: "Plugins::FlexxPluginCrm::AutomatedCampaign"
    has_many :automated_campaign_jobs, class_name: "Plugins::FlexxPluginCrm::AutomatedCampaignJob"
  end
end
