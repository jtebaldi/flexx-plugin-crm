require 'sendgrid-ruby'
require 'twilio-ruby'

class MessagesJobService
  extend SendGrid

  class << self
    # Queue messages with status "to_send" and change their status to "sending"
    def queue_new_messages
      now = Time.now
      Plugins::FlexxPluginCrm::Message.to_send.where('send_at <= ?', now).each do |msg|
        SendMessageWorker.perform_async msg.id
        msg.send_message
      end
      Plugins::FlexxPluginCrm::Email.to_send.where('send_at <= ?', now).each do |email|
        SendEmailWorker.perform_async email.id
        email.send_message
      end
    end

    # Send email message.
    # @param msg [Email] email to send
    # @return [TrueClass, FalseClass] true if the message was sent successfully
    def send_email(email)
      sg_message_id = SendgridAdapter.new.send_email(
        from: {
          email: 'contact@flexx.co',
          name: 'Flexx'
        },
        to: email.email_recipients.map(&:to),
        subject: email.subject,
        body: email.body
      )
      sg_message_id && email.done && email.update(sg_message_id: sg_message_id)
    end

    # Send sms message.
    # @param msg [Message] nessage to send
    # @return [TrueClass, FalseClass] true if the message was sent successfully
    def send_sms(msg)
      resp = TwilioAdapter.new.send_sms to: msg.to_number, body: msg.message
      resp.error_code.zero? && msg.done && msg.update(sid: resp.sid)
    end
  end
end
