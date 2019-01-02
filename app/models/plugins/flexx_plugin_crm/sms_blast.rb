class Plugins::FlexxPluginCrm::SmsBlast < ActiveRecord::Base
  include AASM

  self.table_name = 'sms_blasts'

  belongs_to :site, class_name: 'CamaleonCms::Site'

  has_many :messages, class_name: 'Plugins::FlexxPluginCrm::Message'

  scope :draft, -> { where(aasm_state: 'draft') }
  scope :recent, -> { where(aasm_state: ['sent', 'scheduled']).order(send_at: :desc) }
  scope :scheduled, -> { where(aasm_state: 'scheduled') }
  scope :sent, -> { where(aasm_state: 'sent') }

  aasm do
    state :draft, initial: true
    state :scheduled, :sending, :sent

    event :send_messages, after_commit: :run_worker do
      transitions from: :scheduled, to: :sending
    end

    event :done do
      transitions from: :sending, to: :sent
    end
  end

  private

  def run_worker
  end
end
