module Plugins::FlexxPluginCrm
  class AdminController < CamaleonCms::Apps::PluginsAdminController
    include Plugins::FlexxPluginCrm::MainHelper

    layout "layouts/flexx_next_admin"

    def index
      @active_contacts = current_site.contacts.active
    end

    def contacts
      @active_contacts = current_site.contacts.active.order(:first_name, :email)
    end

    def create_contact
      new_contact = current_site.contacts.create!(new_contact_params)

      redirect_to action: :view_contact, id: new_contact.id
    end

    def contact_card
      @contact = current_site.contacts.find(params[:id])

      render partial: "contact_card"
    end

    def view_contact
      @contact = current_site.contacts.find(params[:id])
    end

    def update_contact
      current_site.contacts.find(params[:id]).update(contact_params)

      redirect_to action: :view_contact, id: params[:id]
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

    def settings
      add_breadcrumb "CRM Settings", :admin_plugins_flexx_plugin_crm_settings_path

      @task_recipes = current_site.task_recipes
      @automated_campaigns = current_site.automated_campaigns.active
    end

    def create_task_recipe
      params[:new_task_recipe].merge!(created_by: current_user.id)

      new_task_recipe = current_site.task_recipes.create(params.require(:new_task_recipe).permit(:title, :created_by))

      redirect_to action: :view_task_recipe, id: new_task_recipe.id
    end

    def view_task_recipe
      @task_recipe = current_site.task_recipes.find(params[:id])
      @available_contact_forms = current_site.
                                  contact_forms.
                                  select(:id, :name).
                                  where(parent_id: nil).
                                  where.not(id: @task_recipe.cama_contact_forms.pluck(:id)).
                                  order(:name)
    end

    def associate_recipe_to_form
      current_site.task_recipes.find(params[:task_recipe_id]).cama_contact_forms << current_site.contact_forms.find(params[:cama_contact_form_id])

      redirect_to action: :view_task_recipe, id: params[:task_recipe_id]
    end

    def create_task_recipe_direction
      current_site.task_recipes.find(params[:task_recipe_id]).directions.create(new_task_recipe_direction_params)

      redirect_to action: :view_task_recipe, id: params[:task_recipe_id]
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

    private

    def new_contact_params
      params.require(:new_contact).permit(:sales_stage, :first_name, :last_name, :email)
    end

    def contact_params
      params.require(:contact).permit(:sales_stage, :first_name, :last_name, :email)
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

    def new_task_recipe_direction_params
      params[:new_task_recipe_direction].merge!(created_by: current_user.id)

      params.require(:new_task_recipe_direction).permit(:task_type, :due_on_value, :due_on_unit, :title, :details, :created_by)
    end

    def new_automated_campaign_step_params
      params[:new_automated_campaign_step].merge!(created_by: current_user.id)

      params.require(:new_automated_campaign_step).permit(:name, :due_on_value, :due_on_unit, :message, :created_by)
    end
  end
end
