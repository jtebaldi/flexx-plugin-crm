class SendgridEventsService
  def self.updateStatus(params)
    params[:_json].each do |p|
      index = p[:sg_message_id].index('.filter')
      message_id = p[:sg_message_id][0, index]

      email = Plugins::FlexxPluginCrm::Email.find_by(sg_message_id: message_id)
      recipient = email.email_recipients.find_by(to: p[:email]) if email

      if recipient
        case p[:event]
        when 'delivered'
          if recipient.delivered_at.nil?
            recipient.delivered_at = Time.current
            recipient.status = p[:event]
          end
        when 'open'
          if recipient.opened_at.nil?
            email.increment!(:opened_count)
            recipient.opened_at = Time.current
            recipient.status = p[:event]
          end
        when 'click'
          if recipient.clicked_at.nil?
            email.increment!(:clicked_count)
            recipient.clicked_at = Time.current
            recipient.status = p[:event]
          end
        when 'unsubscribe'
          email.increment!(:unsubscribed_count) if recipient.unsubscribed_at.nil?
          recipient.unsubscribed_at = Time.current
            recipient.status = 'unsubscribed'
            recipient.contact.email_status = 'unsubscribed'
        when 'bounce'
          if recipient.bounced_at.nil?
            recipient.bounced_at = Time.current
            recipient.status = p[:event]
            recipient.contact.email_status = p[:event]
          end
          email.increment!(:bounced_count)
        when 'dropped'
          recipient.status = p[:event]
          recipient.contact.email_status = p[:event]
          email.increment!(:dropped_count)
        when 'spamreport'
          recipient.status = 'marked_as_spam'
          recipient.contact.email_status = 'marked_as_spam'
          email.increment!(:spam_count)
        end

        recipient.save
        recipient.contact.save
      end
    end
  end
end
