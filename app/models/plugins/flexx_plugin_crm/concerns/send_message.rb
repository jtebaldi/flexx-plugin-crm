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

  # Must be implemented by the class that include this concern
  def run_worker
    raise 'run_worker not implemented'
  end
end
