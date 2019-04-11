class Plugins::FlexxPluginCrm::EmailRecipient < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::ActivityFeed

  self.table_name = 'email_recipients'

  belongs_to :email, class_name: 'Plugins::FlexxPluginCrm::Email'
  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :task, class_name: 'Plugins::FlexxPluginCrm::Task'

  def site
    self.email.site
  end

  def created_by
    self.email.created_by
  end

  def user
    CamaleonCms::User.find_by(id: self.created_by)
  end

  private

  def has_activity_record?
    self.id_changed? && self.task.blank? && self.created_by.present? && self.contact.present?
  end

  def activity_record_params
    if self.task.blank?
      {
        feed_name: 'contact',
        feed_id: self.contact.id,
        args: {
          actor: "User:#{self.created_by}",
          verb: 'sent',
          object: "EmailRecipient:#{self.id}",
          labels: {
            action: 'sent',
            action_type: 'E-mail Blast',
            actor: self.user.print_name
          }
        }
      }
    end
  end
end
