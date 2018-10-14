require 'aasm'

module Plugins::FlexxPluginCrm::Concerns::SendMessage
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm do
      state :scheduled, initial: true
      state :draft, :sending, :sent, :received

      event :send_message do
        transitions from: :scheduled, to: :sending
      end

      event :done do
        transitions from: :sending, to: :sent
      end
    end
  end
end
