module Plugins::FlexxPluginCrm
  class MessagesController < Plugins::FlexxPluginCrm::ApplicationController
    include Plugins::FlexxPluginCrm::Concerns::HasDynamicFields

    layout "layouts/flexx_next_admin"

    def emails
      @recent_emails = current_site.emails.blast.recent.limit(5)
      @scheduled_emails = current_site.emails.blast.scheduled.order(send_at: :desc)
      @sent_emails = current_site.emails.sent.blast.order(send_at: :desc)
      @draft_emails = current_site.emails.draft.blast.order(updated_at: :desc)
    end

    def sms
      @recent_sms = current_site.message_blasts.recent.limit(5)
      @scheduled_sms = current_site.message_blasts.scheduled.order(send_at: :desc)
      @sent_sms = current_site.message_blasts.sent.order(send_at: :desc)
      @draft_sms = current_site.message_blasts.draft.order(updated_at: :desc)
    end

    def new_email
      @email = current_site.emails.build
      @dynamic_fields = { flexxdynamicfields: df_defaults + [['-', '']] + df_snippets }.to_json
      @contacts = current_site.contacts.where.not(email: nil).order(:first_name, :last_name)
      @tags = current_site.owned_tags.order(:name)
    end

    def new_sms
      @dynamic_fields = {
        flexxdynamicfields: df_defaults + [['-', '']] + df_snippets
      }.to_json
      @contacts = current_site.contacts.order(:first_name, :last_name)
      @tags = current_site.owned_tags.order(:name)
    end

    def create_email
      email = current_site.emails.create!(email_params)

      if email.task_id.present?
        head :created
      else
        redirect_to action: :emails
      end
    end

    def edit_email
      @email = current_site.emails.find(params[:id])

      @dynamic_fields = { flexxdynamicfields: df_defaults + [['-', '']] + df_snippets }.to_json
      @contacts = current_site.contacts.where.not(email: nil).order(:first_name, :last_name)
      @tags = current_site.owned_tags.order(:name)

      render :new_email
    end

    def update_email
      email = current_site.emails.find(params[:id]).tap do |email|
        email.update_attributes!(email_params)
      end

      if email.task_id.present?
        head :ok
      else
        redirect_to action: :emails
      end
    end

    def delete_email
      current_site.emails.destroy params[:id]
      flash[:notice] = 'Scheduled email successfully deleted.'
      redirect_to action: :emails
    end

    def create_message
      MessageService.create!(site: current_site, sender: current_user, params: message_params)

      @contact = current_site.contacts.find_by(id: message_params[:contact_id])
    end

    def create_message_blast
      current_site.message_blasts.create!(message_blast_params)

      redirect_to action: :sms
    end

    private

    def email_params
      send_at = if params[:timingOptions] == '2'
        Time.strptime("#{params[:scheduled_date]} #{params[:scheduled_time]} #{Time.current.zone}", '%m/%d/%Y %H:%M %p %Z').in_time_zone
      else
        Time.current
      end

      params[:email].merge!(send_at: send_at)
      params[:email].merge!(created_by: current_user.id)

      params.require(:email).permit(:from, :recipients_list, :subject, :body, :send_at, :created_by, :task_id)
    end

    def message_params
      params.require(:message).permit(:contact_id, :body, :task_id)
    end

    def message_blast_params
      send_at = if params[:timingOptions] == '2'
        Time.strptime("#{params[:scheduled_date]} #{params[:scheduled_time]} #{Time.current.zone}", '%m/%d/%Y %H:%M %p %Z').in_time_zone
      else
        Time.current
      end

      params[:message_blast].merge!(send_at: send_at)
      params[:message_blast].merge!(created_by: current_user.id)

      params.require(:message_blast).permit(:recipients_list, :message, :send_at, :created_by)
    end
  end
end
