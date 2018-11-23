module Plugins::FlexxPluginCrm
  class TasksController < Plugins::FlexxPluginCrm::ApplicationController
    include Plugins::FlexxPluginCrm::Concerns::HasDynamicFields

    layout "layouts/flexx_next_admin"

    def index
      @todays_tasks = current_site.tasks.pending.due_today.order('due_date asc').includes(:contact, :owners)
      @todays_completed_tasks = current_site.tasks.done.done_today.order('updated_at desc').includes(:contact, :owners)
      @upcoming_tasks = current_site.tasks.pending.upcoming.order('due_date asc').includes(:contact, :owners)
      @old_pending_tasks = current_site.tasks.pending.old.order('due_date asc').includes(:contact, :owners)
      @old_completed_tasks = current_site.tasks.done.old.order('updated_at desc').includes(:contact, :owners) - @todays_completed_tasks
      @dynamic_fields = {
        flexxdynamicfields: df_defaults + [['-', '']] + df_snippets
      }.to_json
    end

    def create
      params[:task].merge!(updated_by: current_user.id)
      params[:task][:due_date] = due_date if params[:task][:due_date].present?

      task = current_site.tasks.create(task_params)

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
      task = current_site.tasks.find(params[:task_id])

      params[:task].merge!(updated_by: current_user.id)
      params[:task][:due_date] = due_date if params[:task][:due_date].present?

      task.update(task_params)

      case params[:refresh_panel]
      when 'contact-detail'
        @contact = task.contact
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

    private

    def task_params
      params.require(:task).permit(
        :aasm_state, :contact_id, :task_type, :title, :details, :updated_by, :due_date,
        notes_attributes: [:details, :created_by], owner_ids: []
      )
    end

    def due_date
      Time.strptime(params[:task][:due_date], '%m/%d/%Y - %I:%M %p').in_time_zone
    end
  end
end
