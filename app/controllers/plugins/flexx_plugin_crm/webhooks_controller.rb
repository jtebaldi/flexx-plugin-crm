module Plugins::FlexxPluginCrm
  class WebhooksController < Plugins::FlexxPluginCrm::ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :cama_authenticate

    def twilio_inbound
      return head :not_found unless current_site.get_option('twilio_campaigns_number') == params["To"]

      contact = current_site.phonenumbers.find_by("LENGTH(number) >= 7 AND POSITION(number IN ?) > 0", params["From"]).try(:contact)

      current_site.messages.create(
        contact_id: contact.try(:id),
        sid: params["SmsSid"],
        from_number: params["From"],
        to_number: params["To"],
        message: params["Body"],
        status: params["SmsStatus"]
      )

      head :no_content
    end

    def twilio_status
      message = current_site.messages.find_by(sid: params["SmsSid"])

      return head :not_found if message.blank?

      message.update(status: params["SmsStatus"])

      head :no_content
    end

    def twilio_confirmation
      task = Task.find(params["TaskId"])

      if task
        task.send params["Action"]
        task.save
      end

      head :no_content
    end

    def sendgrid_events
      SendgridEventsService.updateStatus(params)

      head :no_content
    end

    def sendgrid_parse
      SendgridParseService.saveEmail(params)

      head :no_content
    end
  end
end
