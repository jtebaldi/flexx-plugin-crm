module Plugins::FlexxPluginCrm
  class MessagesController < CamaleonCms::Apps::PluginsAdminController
    skip_before_action :verify_authenticity_token
    skip_before_action :cama_authenticate

    def send_email_blast
      EmailBlastService.new(
        recipients: params[:recipients],
        message: params[:message]
      ).call

      head :no_content
    end

    def inbound
        phonenumber = Phonenumber.find_by(number: params["From"])
        contact = Contact.find(phonenumber.contact_id) if phonenumber

        Message.create(
            contact_id: contact ? contact.id : nil,
            site_id: contact ? contact.site_id : nil,
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
  end
end
