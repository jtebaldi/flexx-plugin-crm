module Plugins::FlexxPluginCrm
  class MessagesController < Plugins::FlexxPluginCrm::ApplicationController
    include Plugins::FlexxPluginCrm::Concerns::HasDynamicFields

    layout "layouts/flexx_next_admin"

    #TODO move this callback handle logic to its own controller
    skip_before_action :verify_authenticity_token, only: [:inbound, :status, :confirmation]
    skip_before_action :cama_authenticate, only: [:inbound, :status, :confirmation]

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
      @recent_sms = current_site.sms_blasts.recent.limit(5)
      @scheduled_sms = current_site.sms_blasts.scheduled.order(send_at: :desc)
      @sent_sms = current_site.sms_blasts.sent.order(send_at: :desc)
      @draft_sms = current_site.sms_blasts.draft.order(updated_at: :desc)
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

    def create_text_blast
      text_blast

      respond_to do |format|
        format.js
      end
    end

    private

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

    # @param from_task [Plugind::FlexxPluginCrm::Task, FalseClass, NilClass]
    #   Task if from task, false if from blast, nil if form conversations
    def text_blast(from_task: false)
      recipients_list = params[:recipients].split(',')
      MessageBlastService.new(
        site: current_site,
        user: current_user,
        scheduled_at: nil,
        recipients_list: recipients_list,
        body: params[:body] # DynamicFieldsParserService.parse(site: current_site, template: params[:body], escape: false)
      ).call from_task
      @contact = current_site.contacts.find(recipients_list[0]) if recipients_list.size == 1
    end
  end
end
