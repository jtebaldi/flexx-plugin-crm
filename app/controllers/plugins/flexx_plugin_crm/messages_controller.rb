module Plugins::FlexxPluginCrm
  class MessagesController < CamaleonCms::Apps::PluginsAdminController
    skip_before_action :verify_authenticity_token
    skip_before_action :cama_authenticate

    def inbound
        phonenumber = Phonenumber.find_by(number: params["From"])
        contact = Contact.find(phonenumber.contact_id) if phonenumber

        message = Message.create(
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
  end
end