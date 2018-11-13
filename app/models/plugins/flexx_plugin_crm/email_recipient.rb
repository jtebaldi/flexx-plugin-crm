class Plugins::FlexxPluginCrm::EmailRecipient < ActiveRecord::Base
  self.table_name = 'email_recipients'

  belongs_to :email, class_name: 'Plugins::FlexxPluginCrm::Email'
  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :task, class_name: 'Plugins::FlexxPluginCrm::Task'
end
