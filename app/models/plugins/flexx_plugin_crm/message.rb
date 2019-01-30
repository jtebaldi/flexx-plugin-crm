class Plugins::FlexxPluginCrm::Message < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::SendMessage
  include Plugins::FlexxPluginCrm::Concerns::ActivityFeed

  self.table_name = 'messages'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :site, class_name: 'CamaleonCms::Site'
  belongs_to :task, class_name: 'Plugins::FlexxPluginCrm::Task'
  belongs_to :message_blast, class_name: 'Plugins::FlexxPluginCrm::MessageBlast'

  scope :received, -> { where(status: 'received') }
  scope :unread, -> { where(status: 'received', read: false) }

  before_save :update_message_blast

  private

  def run_worker
    update!(message: DynamicFieldsParserService.parse_contact(site: site, template: message, contact: contact))

    SendMessageWorker.perform_async(id)
  end

  def has_activity_record?
    message_blast.blank? && id_changed?
  end

  def activity_record_params
    if status == 'received' && self.contact.present?
      {
        feed_name: 'notifications',
        feed_id: 'received_messages',
        actor: "Contact:#{self.contact.id}",
        verb: 'sent',
        object: "Message:#{self.id}",
        message: "A new message from #{self.contact.print_name} was received."
      }
    else
      {
        feed_name: 'contact',
        feed_id: self.contact.id,
        actor: "User:#{self.created_by}",
        verb: 'created',
        object: "Message:#{self.id}"
      }
    end
  end

  def update_message_blast
    if self.status == 'delivered' && self.message_blast.present?
      self.message_blast.increment!(:delivered_count)
    end
  end
end
