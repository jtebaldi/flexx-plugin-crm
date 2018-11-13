require 'sendgrid-ruby'
require 'twilio-ruby'

class MessagesJobService
  extend SendGrid

  class << self

    def queue_new_messages
      Plugins::FlexxPluginCrm::Message.scheduled.where('send_at <= ?', Time.current).each do |msg|
        msg.send_message!
      end

      Plugins::FlexxPluginCrm::Message.task_scheduled.where('send_at <= ?', Time.current).each do |msg|
        msg.send_task_message!
      end

      Plugins::FlexxPluginCrm::Email.scheduled.where('send_at <= ?', Time.current).each do |email|
        email.send_message!
      end

      Plugins::FlexxPluginCrm::Email.task_scheduled.where('send_at <= ?', Time.current).each do |email|
        email.send_task_message!
      end
    end

    # Send email message.
    # @param msg [Email] email to send
    # @return [TrueClass, FalseClass] true if the message was sent successfully
    def send_email(email)
      sender = CamaleonCms::User.find_by_email email.from
      if sender
        from = { email: email.from, name: sender.print_name }
      else
        be = CamaleonCms::CustomFieldsRelationship.find_by_custom_field_slug 'business_email'
        from = { email: be.value, name: email.site.name }
      end
      sg_message_id = SendgridAdapter.new(site: email.site).send_email(
        from: from,
        to: email.email_recipients.map { |r| { email: r.to, name: r.contact.print_name } },
        subject: email.subject,
        body: email.body
      )

      if email.sending? # email blast
        email.email_recipients.includes(:contact).each do |r|
          r.create_task(
            contact: r.contact,
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
        message.create_task(
          site: message.site,
          contact: message.contact,
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
