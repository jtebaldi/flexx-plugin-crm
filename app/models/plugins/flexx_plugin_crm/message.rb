class Plugins::FlexxPluginCrm::Message < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::SendMessage

  self.table_name = 'messages'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :site, class_name: 'CamaleonCms::Site'

  scope :received, -> { where(status: 'received') }
  scope :unread, -> { where(status: 'received', read: false) }
end
