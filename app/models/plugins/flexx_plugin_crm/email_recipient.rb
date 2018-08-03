class Plugins::FlexxPluginCrm::EmailRecipient < ActiveRecord::Base
  self.table_name = 'email_recipients'

  belongs_to :email, class_name: 'Plugins::FlexxPluginCrm::Email'
end

