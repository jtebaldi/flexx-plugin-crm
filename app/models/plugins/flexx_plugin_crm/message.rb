class Plugins::FlexxPluginCrm::Message < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include Plugins::FlexxPluginCrm::Concerns::SendMessage
  include Plugins::FlexxPluginCrm::Concerns::ActivityFeed

  self.table_name = 'messages'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :message_blast, class_name: 'Plugins::FlexxPluginCrm::MessageBlast'
  belongs_to :site, class_name: '::CamaleonCms::Site'
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
    self.id_changed? && (self.message_blast.present? || (self.status == 'received' && self.contact_id.present?))
  end

  def activity_record_params
    if self.message_blast.present?
      {
        feed_name: 'contact',
        feed_id: self.contact_id,
        args: {
          actor: "User:#{self.created_by}",
          verb: 'message_sent',
          object: "Message:#{self.id}",
          message: "A SMS Blast was sent by #{self.user.print_name}.",
          labels: {
            action: 'sent',
            action_type: 'SMS Blast',
            actor: self.user.print_name
          },
          url: sms_admin_messages_path(),
          to: ["system:#{self.site_id}"]
        }
      }
    else
      {
        feed_name: 'notifications',
        feed_id: self.site_id,
        args: {
          actor: "Contact:#{self.contact_id}",
          verb: 'message_received',
          object: "Message:#{self.id}",
          message: "A new message was received from #{self.contact.print_name}.",
          url: "#{admin_contact_path(self.contact_id)}#sms"
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
