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

    private

    def task_params
      params.require(:task).permit(:aasm_state, notes_attributes: [:details, :created_by], owner_ids: [])
    end
  end
end
