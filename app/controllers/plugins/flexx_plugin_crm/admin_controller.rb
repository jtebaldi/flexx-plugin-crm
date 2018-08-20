module Plugins::FlexxPluginCrm
  class AdminController < CamaleonCms::Apps::PluginsAdminController
    include Plugins::FlexxPluginCrm::MainHelper

    layout "layouts/flexx_next_admin"

    def index
      @active_contacts = current_site.contacts.active
    end

    def contact_card
      @contact = current_site.contacts.find(params[:id])

      render partial: "contact_card"
    end

    def remove_contact_task
      @contact = current_site.contacts.find(params[:id])
      @contact.tasks.find(params[:task_id]).destroy

      respond_to do |format|
        format.js
      end
    end

    def view_contact
      @contact = current_site.contacts.find(params[:id])
      @automated_campaigns = current_site.automated_campaigns.active
      @subscribed_campaigns = AutomatedCampaignJob.where(contact_id: @contact.id).pluck(:automated_campaign_id)
      @available_recipes = TaskRecipe.all.order(:title)
    end

    def update_contact
      contact = current_site.contacts.find(params[:id])

      contact.update(contact_params)
      current_site.tag(contact, with: params[:contact][:tag_list], on: :tags)

      redirect_to action: :view_contact, id: params[:id]
    end

    def update_contact_status
      @contact = current_site.contacts.find(params[:id])
      @contact.update(sales_stage: params[:contact][:sales_stage],
                      updated_by: current_user.id)

      respond_to do |format|
        format.js
      end
    end

    def create_contact_task
      @contact = current_site.contacts.find(params[:id])

      task = @contact.tasks.create(new_contact_task_params)
      current_site.tag(task, with: params[:new_contact_task][:tag_list], on: :tags)

      respond_to do |format|
        format.js
      end
    end

    def create_contact_message
      contact = current_site.contacts.find(params[:id])

      ContactMessageService.new(
        contact: contact,
        number: params[:phonenumber],
        message: params[:message]
      ).call

      head :ok
    end

    def create_task
      current_site.contacts.find(params[:contact_id]).tasks.create(new_task_params)

      redirect_to action: :view_contact, id: params[:id]
    end

    def update_task
      task = current_site.tasks.find(params[:task_id])
      task.update(task_params)

      redirect_to action: :view_contact, id: task.contact_id
    end

    def task_card
      @task = current_site.tasks.find(params[:id])

      render partial: "plugins/flexx_plugin_crm/tasks/task_card"
    end

    def settings
      add_breadcrumb "CRM Settings", :admin_plugins_flexx_plugin_crm_settings_path

      @task_recipes = current_site.task_recipes
      @automated_campaigns = current_site.automated_campaigns.active.order(:name)
    end

    def recipes
      @active_task_recipes = current_site.task_recipes.active.order(:title)
      @paused_task_recipes = current_site.task_recipes.paused.order(:title)
    end

    def recipe_card
      @task_recipe = current_site.task_recipes.find(params[:id])

      render partial: "recipe_card"
    end

    def create_recipe
      new_task_recipe = current_site.task_recipes.create(new_task_recipe_params)

      redirect_to action: :view_recipe, id: new_task_recipe.id
    end

    def view_recipe
      @task_recipe = current_site.task_recipes.find(params[:id])
      @available_contact_forms = current_site.
                                  contact_forms.
                                  select(:id, :name).
                                  where(parent_id: nil).
                                  order(:name)
    end

    def update_recipe
      @task_recipe = current_site.task_recipes.find(params[:task_recipe_id])

      @task_recipe.update(task_recipe_params)

      head :ok
    end

    def remove_recipe
      current_site.task_recipes.find(params[:id]).update!(
        archived: true,
        archived_by: current_user.id,
        archived_at: Time.now
      )

      redirect_to action: :recipes
    end

    def toggle_recipe
      @task_recipe = current_site.task_recipes.find(params[:id])

      @task_recipe.update(paused: !@task_recipe.paused, paused_by: !@task_recipe.paused ? current_user.id : nil)

      respond_to do |format|
        format.js
      end
    end

    def create_recipe_direction
      @task_recipe = current_site.task_recipes.find(params[:id])

      @task_recipe.directions.create(new_task_recipe_direction_params)

      respond_to do |format|
        format.js
      end
    end

    def create_automated_campaign
      params[:new_automated_campaign].merge!(created_by: current_user.id)

      new_automated_campaign = current_site.automated_campaigns.create(params.require(:new_automated_campaign).permit(:name, :created_by))

      redirect_to action: :view_automated_campaign, id: new_automated_campaign.id
    end

    def view_automated_campaign
      @automated_campaign = current_site.automated_campaigns.find(params[:id])
      @available_contact_forms = current_site.contact_forms.select(:id, :name).where(parent_id: nil)
    end

    def associate_campaign_to_form
      current_site.automated_campaigns.find(params[:automated_campaign_id]).cama_contact_forms << current_site.contact_forms.find(params[:cama_contact_form_id])

      redirect_to action: :view_automated_campaign, id: params[:automated_campaign_id]
    end

    def create_automated_campaign_step
      current_site.automated_campaigns.find(params[:automated_campaign_id]).steps.create(new_automated_campaign_step_params)

      redirect_to action: :view_automated_campaign, id: params[:automated_campaign_id]
    end

    def save_settings
      @plugin.set_options(params[:options]) if params[:options].present? # save option values
      @plugin.set_metas(params[:metas]) if params[:metas].present? # save meta values
      @plugin.set_field_values(params[:field_options]) if params[:field_options].present? # save custom field values
      redirect_to url_for(action: :settings), notice: 'Settings Saved Successfully'
    end

    def list_tags
      render json: current_site.owned_tags.map { |t| { name: t.name, value: t.name } }
    end

    def list_contacts
      render json: current_site.contacts.map { |c| { name: "#{c.print_name} - #{c.email}", value: c.id } }
    end

    private

    def contact_params
      params[:contact][:birthday] = parse_date(params[:contact][:birthday])
      params[:contact].merge!(updated_by: current_user.id)

      params.require(:contact).permit(
        :first_name,
        :last_name,
        :email,
        :source,
        :highlights,
        :address1,
        :address2,
        :city,
        :state,
        :country,
        :postal_code,
        :birthday,
        :updated_by,
        phonenumbers_attributes: [:id, :number, :phone_type]
      )
    end

    def new_task_params
      params[:new_task].merge!(site_id: current_site.id)
      params[:new_task].merge!(created_by: current_user.id)
      params[:new_task].merge!(updated_by: current_user.id)

      params.require(:new_task).permit(:task_type, :due_date, :title, :details, :site_id, :created_by, :updated_by)
    end

    def task_params
      params[:task].merge!(updated_by: current_user.id)

      params.require(:task).permit(:aasm_state, :updated_by, notes_attributes: [:details, :created_by])
    end

    def new_task_recipe_params
      params[:new_task_recipe].merge!(created_by: current_user.id)

      params.require(:new_task_recipe).permit(:title, :description, :created_by)
    end

    def task_recipe_params
      params[:task_recipe].merge!(updated_by: current_user.id)

      params.require(:task_recipe).permit(:cama_contact_form_ids, :updated_by)
    end

    def new_task_recipe_direction_params
      params[:new_task_recipe_direction].merge!(created_by: current_user.id)

      params.require(:new_task_recipe_direction).permit(:task_type, :due_on_value, :due_on_unit, :title, :details, :created_by)
    end

    def new_automated_campaign_step_params
      params[:new_automated_campaign_step].merge!(created_by: current_user.id)

      params.require(:new_automated_campaign_step).permit(:name, :due_on_value, :due_on_unit, :message, :created_by)
    end

    def new_contact_task_params
      params[:new_contact_task].merge!(site_id: current_site.id)
      params[:new_contact_task].merge!(created_by: current_user.id)
      params[:new_contact_task].merge!(updated_by: current_user.id)

      params[:new_contact_task][:due_date] = Time.strptime(params[:new_contact_task][:due_date], '%m/%d/%Y - %I:%M %p')

      params.require(:new_contact_task).permit(:task_type, :due_date, :title, :details, :site_id, :created_by, :updated_by)
    end
  end
end
