class Plugins::FlexxPluginCrm::Message < ActiveRecord::Base
  self.table_name = 'messages'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :site, class_name: 'CamaleonCms::Site'

  scope :to_send, -> { where(status: 'to_send') }
  scope :sending, -> { where(status: 'sending') }
  scope :sent, -> { where(status: 'sent') }
  scope :received, -> { where(status: 'received') }
  scope :unread, -> { where(status: 'received', read: false) }
end
