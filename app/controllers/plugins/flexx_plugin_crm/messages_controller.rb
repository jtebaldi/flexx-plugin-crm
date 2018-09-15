module Plugins::FlexxPluginCrm
  class MessagesController < CamaleonCms::Apps::PluginsAdminController
    layout "layouts/flexx_next_admin"

    #TODO move this callback handle logic to its own controller
    skip_before_action :verify_authenticity_token, only: [:inbound, :status, :confirmation]
    skip_before_action :cama_authenticate, only: [:inbound, :status, :confirmation]

    def index
    end

    def new
    end

    def send_email_blast
      recipients_list = params[:recipients].gsub('___', ' ').split(',')
      recipients = MessagingToolsService.tags_and_contacts_to_emails(recipients: recipients_list)

      EmailBlastService.new(
        site: current_site,
        recipients: recipients,
        subject: params[:subject],
        body: params[:message]
      ).call

      head :no_content
    end

    def create_text_message
      @contact = current_site.contacts.find(params[:contact_id])

      MessageService.new(
        contact: @contact,
        number: params[:phonenumber],
        message: params[:message]
      ).call

      respond_to do |format|
        format.js
      end
    end
  end
end
