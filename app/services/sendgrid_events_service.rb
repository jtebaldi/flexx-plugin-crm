class SendgridEventsService
  def self.updateStatus(params)
    params[:_json].each do |p|
      index = p[:sg_message_id].index('.filter')
      message_id = p[:sg_message_id][0, index]

      email = Plugins::FlexxPluginCrm::Email.find_by(sg_message_id: message_id)
      recipient = email.email_recipients.find_by(to: p[:email]) if email

      if recipient
        case p[:event]
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
            recipient.status = p[:event]
        when 'bounce'
          email.increment!(:bounced_count)
        end

        recipient.save
      end
    end
  end
end

