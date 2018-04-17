require 'aasm'

class Plugins::FlexxPluginCrm::Task < ActiveRecord::Base
  include AASM

  self.table_name = 'tasks'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :site, class_name: 'CamaleonCms::Site'

  aasm do
    state :pending, initial: true
    state :done
  end
end
