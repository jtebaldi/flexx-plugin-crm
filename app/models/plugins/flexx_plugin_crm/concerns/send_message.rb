require 'aasm'

module Plugins::FlexxPluginCrm::Concerns::SendMessage
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm do
      state :scheduled, initial: true
      state :draft, :sending, :task_scheduled, :task_sending, :sent, :task_sent, :received

      event :send_message, after_commit: :run_worker do
        transitions from: :scheduled, to: :sending
      end

      event :send_task_message, after_commit: :run_worker do
        transitions from: :task_scheduled, to: :task_sending
      end

      event :done do
        transitions from: :sending, to: :sent
      end

      event :task_done do
        transitions from: :task_sending, to: :task_sent
      end
    end
  end

  def run_worker
    SendMessageWorker.perform_async self.id if self.class == Plugins::FlexxPluginCrm::Message
    SendEmailWorker.perform_async   self.id if self.class == Plugins::FlexxPluginCrm::Email
  end
end
