module Plugins::FlexxPluginCrm
  class MessagesController < Plugins::FlexxPluginCrm::ApplicationController
    include Plugins::FlexxPluginCrm::Concerns::HasDynamicFields

    layout "layouts/flexx_next_admin"

    def index
      @recent_emails = current_site.emails.where(aasm_state: ['sent', 'scheduled']).order(send_at: :desc).limit(5)
      @scheduled_emails = current_site.emails.where(aasm_state: 'scheduled').order(send_at: :desc)
      @sent_emails = current_site.emails.where(aasm_state: 'sent').order(send_at: :desc)
      @draft_emails = current_site.emails.where(aasm_state: 'draft').order(updated_at: :desc)
    end

    def emails
      @recent_emails = current_site.emails.recent.limit(5)
      @scheduled_emails = current_site.emails.scheduled.order(send_at: :desc)
      @sent_emails = current_site.emails.sent.order(send_at: :desc)
      @draft_emails = current_site.emails.draft.order(updated_at: :desc)
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
      @contacts = current_site.contacts.order(:first_name, :last_name)
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
      task = current_site.tasks.find params[:task_id]
      email_blast from_task: task
      head :created
    end

    def edit_email
      @email = current_site.emails.find params[:id]
      @dynamic_fields = { flexxdynamicfields: df_defaults + [['-', '']] + df_snippets }.to_json
      @contacts = current_site.contacts.order(:first_name, :last_name)
      @tags = current_site.owned_tags.order(:name)
      render :new_email
    end

    def update_email
      scheduled = params[:timingOptions] == '2'
      scheduled_at = params[:scheduled_date] + ' ' + params[:scheduled_time] if scheduled
      email_blast scheduled_at: scheduled_at
      redirect_to action: :emails
    end

    def delete_email
      current_site.emails.destroy params[:id]
      flash[:notice] = 'Scheduled email successfully deleted.'
      redirect_to action: :emails
    end

    def create_email_blast
      scheduled = params[:timingOptions] == '2'
      scheduled_at = params[:scheduled_date] + ' ' + params[:scheduled_time] if scheduled
      email_blast scheduled_at: scheduled_at

      flash[:notice] = 'Email successfully created. You may need to refresh to see sent message.' if !scheduled
      redirect_to action: :emails
    end

    def create_text
      task = current_site.tasks.find_by_id params[:task_id]
      text_blast from_task: task
      if params[:task_id]
        head :created
      else
        render :create_text_blast
      end
    end

    def create_message_blast
      current_site.message_blasts.create!(message_blast_params)

      redirect_to action: :sms
    end

    private

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

    def email_blast(scheduled_at: nil, from_task: nil)
      EmailBlastService.new(
        site: current_site,
        user: current_user,
        scheduled_at: scheduled_at,
        sender: params[:sender],
        recipients_list: params[:recipients],
        subject: params[:subject],
        body: params[:message],
        email_id: params[:id]
      ).call from_task
    end
  end
end
