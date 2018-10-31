require 'sendgrid-ruby'
require 'twilio-ruby'

class MessagesJobService
  extend SendGrid

  class << self

    def queue_new_messages
      Plugins::FlexxPluginCrm::Message.scheduled.where('send_at <= ?', Time.now).each do |msg|
        msg.send_message!
      end

      Plugins::FlexxPluginCrm::Message.tsk_scheduled.where('send_at <= ?', Time.now).each do |msg|
        msg.send_task_message!
      end

      Plugins::FlexxPluginCrm::Email.scheduled.where('send_at <= ?', Time.now).each do |email|
        email.send_message!
      end

      Plugins::FlexxPluginCrm::Email.task_scheduled.where('send_at <= ?', Time.now).each do |email|
        email.send_task_message!
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

      if email.sending? # email blast
        email.email_recipients.each do |r|
          r.contact.tasks.create(
            site: email.site,
            aasm_state: :done,
            created_by: email.created_by,
            details: 'Email blast',
            task_type: :email,
            title: 'Email blast',
            updated_by: email.created_by
          )
        end
      end
      email.update(sg_message_id: sg_message_id) && email.done!
    end

    # Send sms message.
    # @param msg [Message] nessage to send
    # @return [TrueClass, FalseClass] true if the message was sent successfully
    def send_sms(message)
      result = TwilioAdapter.new.send_sms(message: message)
      if message.sending? # sms blast
        message.contact.tasks.create(
          site: message.site,
          aasm_state: :done,
          created_by: message.created_by,
          details: 'SMS blast',
          task_type: :message,
          title: 'SMS blast',
          updated_by: message.created_by
        )
      end
      result.error_code.zero? && message.done! && message.update(sid: result.sid)
    end
  end
end
