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

  private

  def run_worker
    SendMessageWorker.perform_async(id)
  end

  def has_activity_record?
    message_blast.present?
  end

  def activity_record_params
    if message_blast.present?
      {
        task_type: :message,
        title: 'SMS Blast',
        details: message
      }
    end
  end
end
