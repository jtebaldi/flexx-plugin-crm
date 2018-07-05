class ContactMessageService
  def initialize(contact:, number:, message:)
    @contact = contact
    @number = number
    @message = message
  end

  def call
    sms = TwilioAdapter.new.send_sms(to: @number, body: @message)

    @contact.messages.create(
      site_id: @contact.site_id,
      sid: sms.sid,
      from_number: sms.from,
      to_number: sms.to,
      message: sms.body,
      status: sms.status
    )
  end
end
