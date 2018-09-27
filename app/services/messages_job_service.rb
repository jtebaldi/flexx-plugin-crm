require 'sendgrid-ruby'
require 'twilio-ruby'

class MessagesJobService
  extend SendGrid

  class << self
    # Queue messages with status "to_send" and change their status to "sending"
    def queue_new_messages
      Message.to_send.each do |msg|
        SendMessageWorker.perform_async msg.id
        msg.update status: :sending
      end
    end

    # Send message and set it's status to "sent" if operation was successful
    # @param msg [Message]
    def send_message(msg)
      is_sent = case msg.type
                when :email
                  send_email(msg)
                when :sms
                  send_sms(msg)
                end
      is_sent && msg.update(status: :sent)
    end

    private

    # Send email message.
    # @param msg [Message] nessage to send
    # @return [TrueClass, FalseClass] true if the message was sent successfully
    def send_email(msg)
      from = Email.new email: 'info@flexx.comm' # TODO, use email form settings
      to = Email.new email: msg.email
      subject = 'CRM notification'
      content = Content.new type: 'text/plain', value: msg.text
      mail = Mail.new from, subject, to, content
      sg = SendGrid::API.new api_key: Figaro.env.sendgrid_api_key
      resp = sg.client.mail._('send').post(request_body: mail.to_json)
      resp.status_code == '202'
    end

    # Send sms message.
    # @param msg [Message] nessage to send
    # @return [TrueClass, FalseClass] true if the message was sent successfully
    def send_sms(msg)
      client = Twilio::REST::Client.new Figaro.env.twilio_account_sid,
                                        Figaro.env.twilio_auth_token
      resp = client.api.account.messages.create from: Figaro.env.twilio_from,
                                                to: msg.phone,
                                                body: msg.text
      resp.error_code.zero?
    end
  end
end
