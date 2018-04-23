module Plugins::FlexxPluginCrm::Concerns::HasTasks
  extend ActiveSupport::Concern

  included do
    has_many :tasks, class_name: "Plugins::FlexxPluginCrm::Task"
  end
end
