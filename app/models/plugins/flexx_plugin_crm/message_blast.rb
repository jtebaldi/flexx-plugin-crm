require 'aasm'

class Plugins::FlexxPluginCrm::MessageBlast < ActiveRecord::Base
  include AASM

  self.table_name = 'message_blasts'

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
    update!(
      recipients_label: EngageToolsService.message_recipients_to_labels(recipients_list: recipients_list),
      message: DynamicFieldsParserService.parse(site: site, template: message)
    )

    contacts = EngageToolsService.message_recipients_to_contact_list(recipients_list: recipients_list, site: site)

    contacts.each do |c|
      messages.create(
        contact_id: c.id,
        from_number: site.get_option('twilio_campaigns_number'),
        to_number: EngageToolsService.add_country_code(c.phonenumbers.mobile.first.number),
        message: DynamicFieldsParserService.parse_contact(site: site, template: message, contact: c),
        send_at: Time.current,
        created_by: created_by.id
      )
    end
  end
end
