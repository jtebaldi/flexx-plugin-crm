class Plugins::FlexxPluginCrm::Message < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::SendMessage
  include Plugins::FlexxPluginCrm::Concerns::ActivityFeed

  self.table_name = 'messages'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :message_blast, class_name: 'Plugins::FlexxPluginCrm::MessageBlast'
  belongs_to :site, class_name: 'CamaleonCms::Site'
  belongs_to :task, class_name: 'Plugins::FlexxPluginCrm::Task'
  belongs_to :user, class_name: '::CamaleonCms::User', foreign_key: 'created_by'

  scope :received, -> { where(status: 'received') }
  scope :unread, -> { where(status: 'received', read: false) }

  before_save :update_message_blast

  private

  def run_worker
    update!(message: DynamicFieldsParserService.parse_contact(site: site, template: message, contact: contact))

    SendMessageWorker.perform_async(id)
  end

  def has_activity_record?
    self.id_changed? && (self.message_blast.present? || (self.status == 'received' && self.contact.present?))
  end

  def activity_record_params
    if self.message_blast.present?
      {
        feed_name: 'contact',
        feed_id: self.contact.id,
        args: {
          actor: "User:#{self.created_by}",
          verb: 'sent',
          object: "Message:#{self.id}",
          labels: {
            action: 'sent',
            action_type: 'SMS Blast',
            actor: self.user.print_name
          }
        }
      }
    else
      {
        feed_name: 'notifications',
        feed_id: self.site.id,
        args: {
          actor: "Contact:#{self.contact.id}",
          verb: 'sent',
          object: "Message:#{self.id}",
          message: "A new message from #{self.contact.print_name} was received."
        }
      }
    end
  end

  def update_message_blast
    if self.status == 'delivered' && self.message_blast.present?
      self.message_blast.increment!(:delivered_count)
    end
  end
end
