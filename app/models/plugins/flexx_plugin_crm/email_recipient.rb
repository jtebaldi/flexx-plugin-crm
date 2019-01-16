class Plugins::FlexxPluginCrm::EmailRecipient < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::ActivityFeed

  self.table_name = 'email_recipients'

  belongs_to :email, class_name: 'Plugins::FlexxPluginCrm::Email'
  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :task, class_name: 'Plugins::FlexxPluginCrm::Task'

  private

  def has_activity_record?
    task.blank?
  end

  def activity_record_params
    if task.blank?
      {
        task_type: :email,
        title: 'Email Blast',
        details: email.body
      }
    end
  end
end
