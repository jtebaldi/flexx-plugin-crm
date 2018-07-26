module Plugins::FlexxPluginCrm::Concerns::HasUsers
  extend ActiveSupport::Concern

  class_methods do
    def user_class_name
      PluginRoutes.static_system_info['user_model'].presence || 'CamaleonCms::User'
    end

    def user_class
      user_class_name.constantize
    end
  end

  included do
    def user_class
      self.class.user_class
    end
  end
end
