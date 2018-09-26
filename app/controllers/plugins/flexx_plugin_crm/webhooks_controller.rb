module Plugins::FlexxPluginCrm
  class WebhooksController < CamaleonCms::Apps::PluginsAdminController
    skip_before_action :verify_authenticity_token
    skip_before_action :cama_authenticate

    def inbound
        contact = Phonenumber.find_by("LENGTH(number) > 0 AND POSITION(number IN ?) > 0", params["From"]).try(:contact)

        Message.create(
            contact_id: contact.try(:id),
            site_id: contact.try(:site_id),
            sid: params["SmsSid"],
            from_number: params["From"],
            to_number: params["To"],
            message: params["Body"],
            status: params["SmsStatus"]
        )

        head :no_content
    end

    def status
      message = Message.find_by(sid: params["SmsSid"])

      if message
        message.status = params["SmsStatus"]
        message.save
      end

      head :no_content
    end

    def confirmation
      task = Task.find(params["TaskId"])

      if task
        task.send params["Action"]
        task.save
      end

      head :no_content
    end

    def sg_events
      params[:_json].each do |p|
        index = p[:sg_message_id].index('.filter')
        message_id = p[:sg_message_id][0, index]

        email = Email.find_by(sg_message_id: message_id)
        recipient = email.email_recipients.find_by(to: p[:email]) if email

        if recipient
          case p[:event]
          when 'open'
            email.update(opened_count: email.opened_count + 1) if recipient.opened_at.nil?
            recipient.opened_at = Time.now
          when 'click'
            email.update(clicked_count: email.clicked_count + 1) if recipient.clicked_at.nil?
            recipient.clicked_at = Time.now
          when 'unsubscribe'
            email.update(unsubscribed_count: email.unsubscribed_count + 1) if recipient.unsubscribed_at.nil?
            recipient.unsubscribed_at = Time.now
          when 'bounce'
            email.update(bounced_count: email.bounced_count + 1)
          end

          recipient.status = p[:event]
          recipient.save
        end
      end

      head :no_content
    end

    def sg_parse
      envelope = JSON.parse(params[:envelope])

      reply_message_id = $1 if params[:headers] =~ /In-Reply-To:\s<(.+)@/

      email = Email.create(
        subject: params[:subject],
        body: params[:html],
        from: envelope["from"],
        reply_message_id: reply_message_id,
        status: 'received',
      )

      envelope["to"].each do |to|
        email.email_recipients.create(
          to: to,
          status: 'received'
        )
      end

      head :no_content
    end
  end
end
