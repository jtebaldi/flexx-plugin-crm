module Plugins::FlexxPluginCrm::Concerns::HasUsers
  extend ActiveSupport::Concern

  module ClassMethods
    def user_class_name
      PluginRoutes.static_system_info['user_model'].presence || 'CamaleonCms::User'
    end

    def user_class
      user_class_name.constantize
    end
  end
end
