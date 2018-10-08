class Plugins::FlexxPluginCrm::Email < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::SendMessage

  self.table_name = 'emails'

  belongs_to :site, class_name: 'CamaleonCms::Site'
  has_many :email_recipients, class_name: 'Plugins::FlexxPluginCrm::EmailRecipient'
end
