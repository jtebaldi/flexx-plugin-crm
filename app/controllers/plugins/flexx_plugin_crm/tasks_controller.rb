module Plugins::FlexxPluginCrm
  class TasksController < CamaleonCms::Apps::PluginsAdminController
    layout "layouts/flexx_next_admin"

    def index
      @todays_tasks = current_site.tasks.pending.due_today.includes(:contact, :owners)
      @todays_completed_tasks = current_site.tasks.done.due_today.includes(:contact, :owners)
      @upcoming_tasks = current_site.tasks.pending.upcoming.order(:due_date).includes(:contact, :owners)
      @old_pending_tasks = current_site.tasks.pending.old.order(:due_date).includes(:contact, :owners)
      @old_completed_tasks = current_site.tasks.done.old.order(:due_date).includes(:contact, :owners)
    end

    def create
      params[:task].merge!(updated_by: current_user.id)
      params[:task][:due_date] = Time.strptime(params[:task][:due_date], '%m/%d/%Y - %I:%M %p') if params[:task][:due_date].present?

      task = current_site.tasks.create(task_params)

      redirect_to action: :index
    end

    def destroy
      current_site.tasks.find(params[:id]).destroy

      redirect_to action: :index
    end

    def task_owners
      @task = current_site.tasks.find(params[:task_id])
      @current_owners = @task.owners.pluck(:id)

      render partial: 'task_owners'
    end

    def update
      task = current_site.tasks.find(params[:id])

      params[:task].merge!(updated_by: current_user.id)
      params[:task][:due_date] = Time.strptime(params[:task][:due_date], '%m/%d/%Y - %I:%M %p') if params[:task][:due_date].present?

      task.update(task_params)
      current_site.tag(task, with: params[:task][:tag_list], on: :tags)

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
      params[:task][:due_date] = Time.strptime(params[:task][:due_date], '%m/%d/%Y - %I:%M %p') if params[:task][:due_date].present?

      task.update(task_params)

      case params[:refresh_panel]
      when 'contact-detail'
        @contact = task.contact
      when 'tasks-dashboard'
        @todays_tasks = current_site.tasks.pending.due_today.includes(:contact, :owners)
        @upcoming_tasks = current_site.tasks.pending.upcoming.order(:due_date).includes(:contact, :owners)
      end

      respond_to do |format|
        format.js
      end
    end

    def send_task_confirmation
      task = current_site.tasks.find(params[:task_id])

      TaskConfirmationService.new(task: task, number: params[:phonenumber]).call

      head :ok
    end

    private

    def task_params
      params.require(:task).permit(
        :aasm_state, :contact_id, :task_type, :title, :details, :updated_by, :due_date,
        notes_attributes: [:details, :created_by], owner_ids: []
      )
    end
  end
end
