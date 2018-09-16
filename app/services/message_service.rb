class MessageService
  def self.mark_contact_messages_read(contact:)
    contact.messages.where(read: false).update_all(read: true)
  end

  def initialize(contact:, number:, message:)
    @contact = contact
    @number = number
    @message = message
  end

  def call
    sms = TwilioAdapter.new.send_sms(to: recipient, body: @message)

    @contact.messages.create(
      site_id: @contact.site_id,
      sid: sms.sid,
      from_number: sms.from,
      to_number: recipient,
      message: sms.body,
      status: sms.status
    )
  end

  private

  def recipient
    @number[0] == "+" ? @number : "#{@contact.site.get_meta("flexx_crm_settings")[:country_code]}#{@number}"
  end
end
