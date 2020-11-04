require 'sendgrid-ruby'
require 'twilio-ruby'

class MessagesJobService
  extend SendGrid

  def self.queue_new_messages
    Plugins::FlexxPluginCrm::Message.scheduled.where('send_at <= ?', Time.current).each do |message|
      message.send_message!
    end

    Plugins::FlexxPluginCrm::MessageBlast.scheduled.where('send_at <= ?', Time.current).each do |message_blast|
      message_blast.send_messages!
    end

    Plugins::FlexxPluginCrm::Email.scheduled.where('send_at <= ?', Time.current).each do |email|
      email.send_message!
    end
  end

  def self.send_email(message)
    sender = message.site.users.find_by(email: message.from)

    from = if sender
      { email: message.from, name: sender.print_name }
    else
      { email: message.from, name: message.site.name }
    end

    sg_message_id = ""

    message.email_recipients.each_slice(ENV.fetch('SENDGRID_RECIPIENTS_THRESHOLD', '900').to_i) do |recipients|
      sg_id = SendgridAdapter.new(site: message.site).send_email(
        from: from,
        to: recipients.map { |r| { email: r.to, name: r.try(:contact).try(:print_name) } },
        subject: message.subject,
        body: message.body
      )

      sg_message_id = sg_message_id.blank? ? sg_id : "#{sg_message_id}|#{sg_id}"
    end

    message.update!(aasm_state: :sent, sg_message_id: sg_message_id)
  end

  def self.send_message(message)
    result = TwilioAdapter.new.send_sms(message: message)

    if result.error_code.nil?
      message.update!(aasm_state: :sent, sid: result.sid)
    else
      message.update!(aasm_state: :error)
    end
  end
end
