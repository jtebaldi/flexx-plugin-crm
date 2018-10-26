require 'aasm'

module Plugins::FlexxPluginCrm::Concerns::SendMessage
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm do
      state :scheduled, initial: true
      state :draft, :sending, :sent, :received

      event :send_message, after_commit: :run_worker do
        transitions from: :scheduled, to: :sending
      end

      event :done do
        transitions from: :sending, to: :sent
      end
    end
  end

  def run_worker
    SendMessageWorker.perform_async self.id if self.class == Plugins::FlexxPluginCrm::Message
    SendEmailWorker.perform_async   self.id if self.class == Plugins::FlexxPluginCrm::Email
  end
end
