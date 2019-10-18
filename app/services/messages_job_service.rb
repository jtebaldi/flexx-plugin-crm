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

  def self.queue_campaigns
    active_campaigns = Plugins::FlexxPluginCrm::AutomatedCampaign.active.pluck(:id)
    subscriptions = Plugins::FlexxPluginCrm::AutomatedCampaignSubscription.running
      .includes(:campaign)
      .where(automated_campaign_id: active_campaigns)
      .where('next_send_at <= ?', Time.current)

    subscriptions.each do |s|
      site = s.campaign.site
      step = Plugins::FlexxPluginCrm::AutomatedCampaignSubscriptionStep.find(s.next_step)

      site.emails.create!({
        from: site.custom_field_values.find_by_custom_field_slug('business_email'),
        recipients_list: s.contact_id,
        subject: step.campaign_step.stock.metadata["subject"],
        body: step.campaign_step.stock.contents,
        send_at: step.send_at
      })

      step.update!(aasm_state: :done)
    end
  end

  def self.send_email(message)
    sender = message.site.users.find_by(email: message.from)

    from = if sender
      { email: message.from, name: sender.print_name }
    else
      { email: message.from, name: message.site.name }
    end

    sg_message_id = SendgridAdapter.new(site: message.site).send_email(
      from: from,
      to: message.email_recipients.map { |r| { email: r.to, name: r.try(:contact).try(:print_name) } },
      subject: message.subject,
      body: message.body
    )

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
