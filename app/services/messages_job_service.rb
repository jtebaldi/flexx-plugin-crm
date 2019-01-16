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

    Plugins::FlexxPluginCrm::Email.task_scheduled.where('send_at <= ?', Time.current).each do |email|
      email.send_task_message!
    end
  end

  def self.send_email(email)
    sender = CamaleonCms::User.find_by_email email.from
    if sender
      from = { email: email.from, name: sender.print_name }
    else
      be = email.site.custom_field_values.find_by_custom_field_slug 'business_email'
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
      email.update(sg_message_id: sg_message_id) && email.done!
    else
      email.update(sg_message_id: sg_message_id) && email.task_done!
    end
  end

  def self.send_message(message)
    result = TwilioAdapter.new.send_sms(message: message)

    if result.error_code.zero?
      message.update!(aasm_state: :sent, sid: result.sid)
    else
      message.update!(aasm_state: :error)
    end
  end
end
