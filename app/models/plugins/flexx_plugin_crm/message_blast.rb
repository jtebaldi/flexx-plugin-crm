require 'aasm'

class Plugins::FlexxPluginCrm::MessageBlast < ActiveRecord::Base
  include AASM

  self.table_name = 'message_blasts'

  belongs_to :site, class_name: 'CamaleonCms::Site'

  has_many :messages, class_name: 'Plugins::FlexxPluginCrm::Message'

  before_create :recipients_to_labels
  after_create :send_immediate_messages

  scope :draft, -> { where(aasm_state: 'draft') }
  scope :recent, -> { where(aasm_state: ['sending', 'sent', 'scheduled']).order(send_at: :desc) }
  scope :scheduled, -> { where(aasm_state: 'scheduled') }
  scope :sent, -> { where(aasm_state: 'sent') }

  aasm do
    state :scheduled, initial: true
    state :draft, :sending, :sent

    event :send_messages, after_commit: :run_worker do
      transitions from: :scheduled, to: :sending
    end

    event :done do
      transitions from: :sending, to: :sent
    end
  end

  private

  def recipients_to_labels
    self.recipients_label = EngageToolsService.message_recipients_to_labels(recipients_list: recipients_list)
  end

  def send_immediate_messages
    self.send_messages! if self.send_at.present? && self.send_at <= Time.current
  end

  def run_worker
    update!(message: DynamicFieldsParserService.parse(site: site, template: message))

    contacts = EngageToolsService.message_recipients_to_contacts_list(recipients_list: recipients_list, site: site)

    contacts.each do |c|
      messages.create!(
        site_id: site_id,
        contact_id: c[0].id,
        from_number: site.get_option('twilio_campaigns_number'),
        to_number: EngageToolsService.add_country_code(site: site, number: c[1]),
        message: DynamicFieldsParserService.parse_contact(site: site, template: message, contact: c[0]),
        send_at: Time.current,
        created_by: created_by
      )
    end

    done!
  end
end
