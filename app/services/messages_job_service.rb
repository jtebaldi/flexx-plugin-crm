require 'sendgrid-ruby'
require 'twilio-ruby'

class MessagesJobService
  extend SendGrid

  class << self
    # Queue messages with status "to_send" and change their status to "sending"
    def queue_new_messages
      Plugins::FlexxPluginCrm::Message.to_send.each do |msg|
        SendMessageWorker.perform_async msg.id
        msg.update status: :sending
      end
      Plugins::FlexxPluginCrm::EmailRecipient.to_send do |recipient|
        SendEmailWorker.perform_async recipient.id
        recipient.update status: :sending
      end
    end

    # Send email message.
    # @param msg [Message] nessage to send
    # @return [TrueClass, FalseClass] true if the message was sent successfully
    def send_email(recipient)
      from = Email.new email: 'info@flexx.comm' # TODO, use email form settings
      to = Email.new email: recipient.to
      subject = recipient.email.subject
      content = Content.new type: 'text/plain', value: recipient.email.body
      mail = Mail.new from, subject, to, content
      sg = SendGrid::API.new api_key: ENV['SENDGRID_API_KEY']
      resp = sg.client.mail._('send').post(request_body: mail.to_json)
      resp.status_code == '202' && recipient.update(status: :sent)
    end

    # Send sms message.
    # @param msg [Message] nessage to send
    # @return [TrueClass, FalseClass] true if the message was sent successfully
    def send_sms(msg)
      client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'],
                                        ENV['TWILIO_ACCOUNT_TOKEN']
      resp = client.api.account.messages.create from: ENV['TWILIO_FROM'],
                                                to: msg.to_number,
                                                body: msg.message
      resp.error_code.zero? && msg.update(status: :sent, sid: resp.sid)
    end
  end
end
