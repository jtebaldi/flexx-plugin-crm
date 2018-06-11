module Plugins::FlexxPluginCrm
  class TasksController < CamaleonCms::Apps::PluginsAdminController
    include Plugins::FlexxPluginCrm::MainHelper

    layout "layouts/flexx_next_admin"

    def index
      @todays_tasks = current_site.tasks.pending.due_today.includes(:contact, :owners)
      @upcoming_tasks = current_site.tasks.pending.upcoming.order(:due_date).includes(:contact, :owners)
    end

    def task_owners
      @current_owners = current_site.tasks.find(params[:task_id]).owners.pluck(:id)
      render partial: 'task_owners'
    end

    def update
      task = current_site.tasks.find(params[:id])
      task.update(task_params)
    end

    private

    def task_params
      params.require(:task).permit(:owner_ids)
    end
  end
end
