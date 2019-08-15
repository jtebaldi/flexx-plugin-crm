module Plugins::FlexxPluginCrm
  class WebhooksController < Plugins::FlexxPluginCrm::ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :cama_authenticate

    def twilio_inbound
      return head :not_found unless current_site.get_option('twilio_campaigns_number') == params["To"]

      contact = current_site.phonenumbers.joins(:contact).find_by("LENGTH(number) >= 7 AND POSITION(number IN ?) > 0 AND contacts.sales_stage != ?", params["From"], :archived).try(:contact)

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

    def zap_new_contact
      if request.headers['X-FLEXX-WEBHOOK'] == 'zapier' && request.headers['Content-Type'] == 'application/json'
        # data = JSON.parse(request.body.read)
        source = request.headers['X-LEAD-SOURCE'] || "Zapier"
      end

      return head :bad_request if params[:email].blank?
  
      if params[:email].present?
        contact = current_site.contacts.find_or_create_by email: params[:email] do |c|
          c.first_name =  params[:first_name]
          c.last_name = params[:last_name]
          c.email = params[:email]
          c.source = source
        end

        if params[:phonenumber].present?
          number = if params[:phonenumber] !~ /^\+/ && params[:phonenumber].length == 10
            '+1' + params[:phonenumber]
          else
            params[:phonenumber]
          end
    
          contact.phonenumbers.find_or_create_by number: number do |p|
            p.site = current_site
          end
        end
      end
  
      head :ok
    end

  end
end
