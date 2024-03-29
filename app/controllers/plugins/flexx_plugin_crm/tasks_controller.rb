module Plugins::FlexxPluginCrm
  class TasksController < Plugins::FlexxPluginCrm::ApplicationController
    include Plugins::FlexxPluginCrm::Concerns::HasDynamicFields

    layout "layouts/flexx_next_admin"

    def index
      @todays_tasks = current_site.tasks.pending.due_today.order('due_date asc').includes(:contact, :owners)
      @todays_completed_tasks = current_site.tasks.done.done_today.order('updated_at desc').includes(:contact, :owners)
      @upcoming_tasks = current_site.tasks.pending.upcoming.order('due_date asc').includes(:contact, :owners)
      @old_pending_tasks = current_site.tasks.pending.old.order('due_date asc').includes(:contact, :owners)

      # Only included last 7 days of completed tasks to avoid timeout on tasks index
      @last7_completed_tasks = current_site.tasks.done.old.where('created_at >= ?', 1.week.ago).order('updated_at desc').includes(:contact, :owners) - @todays_completed_tasks
      @old_completed_tasks = current_site.tasks.done.old.order('updated_at desc').includes(:contact, :owners) - @todays_completed_tasks
      @dynamic_fields = {
        flexxdynamicfields: df_defaults + [['-', '']] + df_snippets
      }.to_json
    end

    def create
      params[:task].merge!(updated_by: current_user.id)
      params[:task][:due_date] = due_date if params[:task][:due_date].present?

      current_site.tasks.create(task_params)

      redirect_to action: :index
    end

    def destroy
      task = current_site.tasks.find(params[:id])
      task.destroy

      case params[:refresh_panel]
      when 'tasks-dashboard'
        @todays_tasks = current_site.tasks.pending.due_today.order('due_date asc').includes(:contact, :owners)
        @todays_completed_tasks = current_site.tasks.done.done_today.order('updated_at desc').includes(:contact, :owners)
        @upcoming_tasks = current_site.tasks.pending.upcoming.order('due_date asc').includes(:contact, :owners)
        @old_pending_tasks = current_site.tasks.pending.old.order('due_date asc').includes(:contact, :owners)
        @old_completed_tasks = current_site.tasks.done.old.order('updated_at desc').includes(:contact, :owners) - @todays_completed_tasks
      when 'view-contact-tasks-panels'
        @contact = task.contact
        @feed_activities = ActivityFeedService.list_activities(feed_name: 'contact', feed_id: @contact.id)
      end

      respond_to do |format|
        format.js { render :update }
      end
    end

    def task_owners
      @task = current_site.tasks.find(params[:task_id])
      @current_owners = @task.owners.pluck(:id)

      render partial: 'task_owners'
    end

    def update
      task = current_site.tasks.find(params[:id])

      params[:task].merge!(updated_by: current_user.id)
      params[:task][:due_date] = due_date if params[:task][:due_date].present?

      params[:task][:notes_attributes].delete_at 0 if params[:task][:notes_attributes] && params[:task][:notes_attributes][0][:details].empty?
      task.update(task_params)
      current_site.tag(task, with: params[:task][:tag_list], on: :tags)

      case params[:refresh_panel]
      when 'tasks-dashboard'
        @todays_tasks = current_site.tasks.pending.due_today.order('due_date asc').includes(:contact, :owners)
        @todays_completed_tasks = current_site.tasks.done.done_today.order('updated_at desc').includes(:contact, :owners)
        @upcoming_tasks = current_site.tasks.pending.upcoming.order('due_date asc').includes(:contact, :owners)
        @old_pending_tasks = current_site.tasks.pending.old.order('due_date asc').includes(:contact, :owners)
        @old_completed_tasks = current_site.tasks.done.old.order('updated_at desc').includes(:contact, :owners) - @todays_completed_tasks
      when 'view-contact-tasks-panels'
        @contact = task.contact
        @feed_activities = ActivityFeedService.list_activities(feed_name: 'contact', feed_id: @contact.id)
      end

      respond_to do |format|
        format.js
      end
    end

    def create_note
      @task = current_site.tasks.find(params[:id])

      @task.notes.create(details: params[:text], created_by: current_user.id)

      render partial: 'notes'
    end

    def update_note
      Plugins::FlexxPluginCrm::Note.update(params[:note_id], details: params[:text])
      head :no_content
    end

    def delete_note
      Plugins::FlexxPluginCrm::Note.destroy(params[:note_id])
      head :no_content
    end

    def defer_task
      @task = current_site.tasks.find(params[:task_id])

      params[:task].merge!(updated_by: current_user.id)
      params[:task][:due_date] = due_date if params[:task][:due_date].present?

      @task.update(task_params)

      case params[:refresh_panel]
      when 'contact-detail'
        @contact = @task.contact
        @feed_activities = ActivityFeedService.list_activities(feed_name: 'contact', feed_id: @contact.id)
      when 'tasks-dashboard'
        @todays_tasks = current_site.tasks.pending.due_today.order('due_date asc').includes(:contact, :owners)
        @upcoming_tasks = current_site.tasks.pending.upcoming.order('due_date asc').includes(:contact, :owners)
        @old_pending_tasks = current_site.tasks.pending.old.order('due_date asc').includes(:contact, :owners)
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

    def create_stock
      current_site.stocks.create!(stock_task_params.merge(contents: '', created_by: current_user.id))
    end

    def stock_card
      @stock_task = current_site.stocks.tasks.find(params[:id])

      render partial: "plugins/flexx_plugin_crm/tasks/stock_card"
    end

    def update_stock
      stock_task = current_site.stocks.tasks.find(params[:id])
      stock_task.updated_by = current_user.id
      stock_task.update(stock_task_params)
    end

    def delete_stock
      stock_task = current_site.stocks.tasks.find(params[:id])

      stock_task.destroy

      render :update_stock
    end

    private

    def task_params
      params.require(:task).permit(
        :aasm_state, :contact_id, :task_type, :title, :details, :updated_by, :due_date,
        notes_attributes: [:details, :created_by], owner_ids: []
      )
    end

    def due_date
      Time.strptime("#{params[:task][:due_date]} #{Time.current.zone}", '%m/%d/%Y - %I:%M %p %Z').in_time_zone
    end

    def stock_task_params
      params.require(:stock_task).permit(:stock_type, :name, :description, :contents, :created_by, :updated_by, metadata: :task_type)
    end
  end
end
