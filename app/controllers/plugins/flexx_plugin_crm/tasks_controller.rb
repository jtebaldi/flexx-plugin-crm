module Plugins::FlexxPluginCrm
  class TasksController < CamaleonCms::Apps::PluginsAdminController
    layout "layouts/flexx_next_admin"

    def index
      @todays_tasks = current_site.tasks.pending.due_today.includes(:contact, :owners)
      @upcoming_tasks = current_site.tasks.pending.upcoming.order(:due_date).includes(:contact, :owners)
    end

    def task_owners
      @task = current_site.tasks.find(params[:task_id])
      @current_owners = @task.owners.pluck(:id)

      render partial: 'task_owners'
    end

    def update
      task = current_site.tasks.find(params[:id])

      params[:task].merge!(updated_by: current_user.id)
      params[:task][:due_date] = DateTime.strptime(params[:task][:due_date], '%m/%d/%Y - %I:%M %p') if params[:task][:due_date].present?

      task.update(task_params)

      case params[:refresh_panel]
      when 'todays-tasks-list'
        @todays_tasks = current_site.tasks.pending.due_today.includes(:contact, :owners)
      when 'upcoming-tasks-list'
        @upcoming_tasks = current_site.tasks.pending.upcoming.order(:due_date).includes(:contact, :owners)
      when 'view-contact-tasks-panels'
        @contact = task.contact
      end

      respond_to do |format|
        format.js
      end
    end

    def defer_task
      task = current_site.tasks.find(params[:task_id])

      params[:task].merge!(updated_by: current_user.id)
      params[:task][:due_date] = DateTime.strptime(params[:task][:due_date], '%m/%d/%Y - %I:%M %p') if params[:task][:due_date].present?

      task.update(task_params)

      @contact = task.contact

      respond_to do |format|
        format.js
      end
    end

    def send_task_confirmation
      task = current_site.tasks.find(params[:task_id])

      if task.nil?
        head :bad_request
      end

      flow_params = {
        task_id: task.id,
        due_time: task.due_date
      }

      flow = twilio_client.studio.flows(ENV["TWILIO_CONFIRMATION_FLOW_SID"]).engagements.create(
          from: ENV["TWILIO_NUMBER"],
          to: params[:task_confirmation][:phonenumber],
          parameters: flow_params.to_json
      )

      task.notes.create(
        details: 'Confirmation message sent',
        created_by: current_user.id
      )

      head :ok
    end

    private

    def task_params
      params.require(:task).permit(
        :aasm_state, :updated_by, :due_date, :tag_list, notes_attributes: [:details, :created_by], owner_ids: []
      )
    end

    def twilio_client
      account_sid = ENV["TWILIO_ACCOUNT_SID"]
      auth_token = ENV["TWILIO_AUTH_TOKEN"]

      Twilio::REST::Client.new account_sid, auth_token
    end
  end
end
