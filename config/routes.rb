Rails.application.routes.draw do
  scope PluginRoutes.system_info["relative_url_root"] do
    scope :admin, as: 'admin', path: PluginRoutes.system_info['admin_path_name'] do
      namespace 'plugins' do
        namespace 'flexx_plugin_crm' do
          controller :admin do
            get :index
            get :settings
            post :save_settings

            get :new_contact
            get '/view_contact/:id', action: :view_contact, as: :view_contact
            post :create_contact
            post '/update_contact/:id', action: :update_contact, as: :update_contact

            post '/create_task/:contact_id', action: :create_task, as: :create_task
            post '/update_task/:task_id', action: :update_task, as: :update_task

            get 'view_task_recipe/:id', action: :view_task_recipe, as: :view_task_recipe
            post :create_task_recipe
            post 'create_task_recipe_direction/:task_recipe_id', action: :create_task_recipe_direction, as: :create_task_recipe_direction
            post 'associate_recipe_to_form/:task_recipe_id', action: :associate_recipe_to_form, as: :associate_recipe_to_form

            get 'view_automated_campaign/:id', action: :view_automated_campaign, as: :view_automated_campaign
            post :create_automated_campaign
            post 'create_automated_campaign_step/:automated_campaign_id', action: :create_automated_campaign_step, as: :create_automated_campaign_step
          end
        end
      end
    end
  end
end
