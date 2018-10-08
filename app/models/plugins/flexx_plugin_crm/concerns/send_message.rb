require 'aasm'

module Plugins::FlexxPluginCrm::Concerns::SendMessage
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm do
      state :to_send, initial: true
      state :sending, :sent

      event :send_message do
        transitions from: :to_send, to: :sending
      end

      event :done do
        transitions from: :sending, to: :sent
      end
    end
  end
end
