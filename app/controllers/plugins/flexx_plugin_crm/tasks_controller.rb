module Plugins::FlexxPluginCrm
  class TasksController < CamaleonCms::Apps::PluginsAdminController
    include Plugins::FlexxPluginCrm::MainHelper

    layout "layouts/flexx_next_admin"

    def index
      @todays_tasks = current_site.tasks.pending.due_today.includes(:contact)
      @upcoming_tasks = current_site.tasks.pending.upcoming.order(:due_date).includes(:contact)
    end
  end
end
