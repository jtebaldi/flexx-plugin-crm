class MessageBlastService
  def self.mark_contact_messages_read(contact:)
    contact.messages.where(read: false).update_all(read: true)
  end

  def initialize(site:, user:, scheduled_at:, recipients_list:, body:)
    @site = site
    @user = user
    @scheduled_at = scheduled_at
    @recipients_list = recipients_list
    @body = body
  end

  def call(task = nil)
    send_at = @scheduled_at.present? ?
      Time.strptime("#{@scheduled_at} #{Time.current.zone}", '%m/%d/%Y %H:%M %p %Z').in_time_zone :
      Time.current

    contacts = @site.contacts.includes(:phonenumbers).where(id: @recipients_list)

    contacts.each do |contact|
      message = @site.messages.create(
        task: task,
        contact_id: contact.id,
        from_number: @site.get_option('twilio_campaigns_number'),
        to_number: with_country_code(contact.phonenumbers.mobile.first.number),
        message: DynamicFieldsParserService.parse_contact(site: @site, template: @body, contact: contact, escape: false),
        aasm_state: (task ? :task_scheduled : :scheduled),
        send_at: send_at,
        created_by: @user.id
      )

      unless @scheduled_at.present?
        if task
          message.send_task_message!
        else
          message.send_message!
        end
      end
    end
  end

  private

  def with_country_code(number)
    number[0] == "+" ? number : "#{@site.get_meta("flexx_crm_settings")[:country_code]}#{number}"
  end
end
