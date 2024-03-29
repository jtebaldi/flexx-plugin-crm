class Plugins::FlexxPluginCrm::Email < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::SendMessage

  self.table_name = 'emails'

  belongs_to :site, class_name: 'CamaleonCms::Site'

  has_many :email_recipients, class_name: 'Plugins::FlexxPluginCrm::EmailRecipient', dependent: :destroy

  before_save :recipients_to_labels

  scope :draft, -> { where(aasm_state: 'draft') }
  scope :recent, -> { where(aasm_state: ['sent', 'scheduled', 'sending']).order(send_at: :desc) }
  scope :scheduled, -> { where(aasm_state: 'scheduled') }
  scope :sent, -> { where(aasm_state: 'sent') }
  scope :blast, -> { where(task_id: nil) }

  private

  def run_worker
    contact_list = EngageToolsService.email_recipients_to_contacts_list(recipients_list: recipients_list, site: site)

    update!(
      body: DynamicFieldsParserService.parse(site: site, template: body),
      recipients_count: contact_list.count
    )

    contact_list.each do |c|
      email_recipients.create!(contact_id: c[0], to: c[1], task_id: task_id)
    end

    SendEmailWorker.perform_async(id)
  end

  def recipients_to_labels
    if self.recipients_list_was != self.recipients_list
      self.recipients_label = EngageToolsService.message_recipients_to_labels(recipients_list: recipients_list)
    end
  end
end
