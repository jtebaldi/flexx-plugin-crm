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

        if email
          case p[:event]
          when 'open'
            email.opened_count += 1
          when 'click'
            email.clicked_count += 1
          when 'bounce'
            email.bounced_count += 1
          when 'unsubscribe'
            email.unsubscribed_count += 1
          end
          email.save

          recipient = email.email_recipients.find_by(to: p[:email])
          recipient.update(status: p[:event]) if recipient
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
