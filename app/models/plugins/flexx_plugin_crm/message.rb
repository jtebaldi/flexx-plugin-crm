class Plugins::FlexxPluginCrm::Message < ActiveRecord::Base
  self.table_name = 'messages'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'

  scope :sent, -> { where(status: 'sent') }
  scope :received, -> { where(status: 'received') }
  scope :unread, -> { where(status: 'received', read: false) }
end
