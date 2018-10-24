require 'sendgrid-ruby'
require 'twilio-ruby'

class MessagesJobService
  extend SendGrid

  class << self

    def queue_new_messages
      Plugins::FlexxPluginCrm::Message.scheduled.where('send_at <= ?', Time.now).each do |msg|
        msg.send_message!
      end

      Plugins::FlexxPluginCrm::Email.scheduled.where('send_at <= ?', Time.now).each do |email|
        email.send_message!
      end
    end

    # Send email message.
    # @param msg [Email] email to send
    # @return [TrueClass, FalseClass] true if the message was sent successfully
    def send_email(email)
      sg_message_id = SendgridAdapter.new(site: email.site).send_email(
        from: {
          email: email.from,
          name: email.site.name
        },
        to: email.email_recipients.map(&:to),
        subject: email.subject,
        body: email.body
      )
      email.update(sg_message_id: sg_message_id) && email.done!
    end

    # Send sms message.
    # @param msg [Message] nessage to send
    # @return [TrueClass, FalseClass] true if the message was sent successfully
    def send_sms(msg)
      resp = TwilioAdapter.new.send_sms to: msg.to_number, body: msg.message
      resp.error_code.zero? && msg.done! && msg.update(sid: resp.sid)
    end
  end
end
