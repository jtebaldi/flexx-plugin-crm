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
          email.increment!(:opened_count) if recipient.opened_at.nil?
          recipient.opened_at = Time.now
        when 'click'
          email.increment!(:clicked_count) if recipient.clicked_at.nil?
          recipient.clicked_at = Time.now
        when 'unsubscribe'
          email.increment!(:unsubscribed_count) if recipient.unsubscribed_at.nil?
          recipient.unsubscribed_at = Time.now
        when 'bounce'
          email.increment!(:bounced_count)
        end

        recipient.status = p[:event]
        recipient.save
      end
    end
  end
end

