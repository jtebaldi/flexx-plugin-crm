Rails.application.config.to_prepare do
  CamaleonCms::Site.class_eval do
    include Plugins::FlexxPluginCrm::Concerns::HasContacts
  end
end
