class Plugins::FlexxPluginCrm::Email < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::SendMessage

  self.table_name = 'emails'

  belongs_to :site, class_name: 'CamaleonCms::Site'

  has_many :email_recipients, class_name: 'Plugins::FlexxPluginCrm::EmailRecipient', dependent: :destroy

  scope :draft, -> { where(aasm_state: 'draft') }
  scope :recent, -> { where(aasm_state: ['sent', 'scheduled']).order(send_at: :desc) }
  scope :scheduled, -> { where(aasm_state: 'scheduled') }
  scope :sent, -> { where(aasm_state: 'sent') }

  private

  def run_worker
    SendEmailWorker.perform_async(id)
  end
end
