class Plugins::FlexxPluginCrm::TaskOwner < ActiveRecord::Base
  self.table_name = 'task_owners'

  belongs_to :task, class_name: 'Plugins::FlexxPluginCrm::Task'
  belongs_to :owner, class_name: 'CamaleonCms::User'
end
