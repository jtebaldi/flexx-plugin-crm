require 'aasm'

module Plugins::FlexxPluginCrm::Concerns::SendMessage
  extend ActiveSupport::Concern

  included do
    include AASM

    after_create :send_immediate_message

    aasm do
      state :scheduled, initial: true
      state :draft, :sending, :sent, :received, :error

      event :send_message, after_commit: :run_worker do
        transitions from: :scheduled, to: :sending
      end

      event :done do
        transitions from: :sending, to: :sent
      end
    end
  end

  # Must be implemented by the class that include this concern
  def run_worker
    raise 'run_worker not implemented'
  end

  def send_immediate_message
    self.send_message! if self.send_at <= Time.current
  end
end
