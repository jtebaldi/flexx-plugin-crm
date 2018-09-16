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

        logger.debug "Message #{message_id} to #{p[:email]} - #{p[:event]}"
      end

      head :no_content
    end
  end
end
