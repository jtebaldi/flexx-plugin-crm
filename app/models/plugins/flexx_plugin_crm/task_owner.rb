class Plugins::FlexxPluginCrm::TaskOwner < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::HasUsers

  self.table_name = 'task_owners'

  belongs_to :task, class_name: 'Plugins::FlexxPluginCrm::Task'
  belongs_to :owner, class_name: user_class_name
end
