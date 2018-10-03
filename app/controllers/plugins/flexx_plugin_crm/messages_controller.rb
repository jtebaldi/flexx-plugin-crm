module Plugins::FlexxPluginCrm
  class MessagesController < CamaleonCms::Apps::PluginsAdminController
    layout "layouts/flexx_next_admin"

    #TODO move this callback handle logic to its own controller
    skip_before_action :verify_authenticity_token, only: [:inbound, :status, :confirmation]
    skip_before_action :cama_authenticate, only: [:inbound, :status, :confirmation]

    def index
      @recent_emails = current_site.emails.where(status: ['sent', 'scheduled']).order(send_at: :desc).limit(5)
      @scheduled_emails = current_site.emails.where(status: 'scheduled').order(send_at: :desc)
      @sent_emails = current_site.emails.where(status: 'sent').order(send_at: :desc)
      @draft_emails = current_site.emails.where(status: 'draft').order(updated_at: :desc)
    end

    def new
    end

    def create_email_blast
      scheduled = params[:timingOptions2] == '2'
      scheduled_at = params[:scheduled_date] + ' ' + params[:scheduled_time] if scheduled

      EmailBlastService.new(
        site: current_site,
        user: current_user,
        scheduled_at: scheduled_at,
        recipients_list: params[:recipients],
        subject: params[:subject],
        body: params[:message]
      ).call

      redirect_to action: :index
    end

    def create_text_blast
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
