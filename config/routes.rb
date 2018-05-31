Rails.application.routes.draw do
  scope PluginRoutes.system_info["relative_url_root"] do
    scope :admin, as: 'admin', path: PluginRoutes.system_info['admin_path_name'] do
      scope :next do
        get :contacts, controller: 'plugins/flexx_plugin_crm/admin', action: :contacts
        get 'contact_card/:id', controller: 'plugins/flexx_plugin_crm/admin', action: :contact_card
        get 'contacts/:id', controller: 'plugins/flexx_plugin_crm/admin', action: :view_contact, as: :view_contact

        get  :recipes, controller: 'plugins/flexx_plugin_crm/admin', action: :recipes
        get  'recipe_card/:id', controller: 'plugins/flexx_plugin_crm/admin', action: :recipe_card
        get  'recipes/:id', controller: 'plugins/flexx_plugin_crm/admin', action: :view_recipe, as: :view_recipe
        post :create_recipe, controller: 'plugins/flexx_plugin_crm/admin', action: :create_recipe, as: :create_recipe
      end

      namespace 'plugins' do
        namespace 'flexx_plugin_crm' do
          controller :admin do
            get :index
            get :settings
            post :save_settings

            get :new_contact
            post :create_contact
            post '/update_contact/:id', action: :update_contact, as: :update_contact

            post '/create_task/:contact_id', action: :create_task, as: :create_task
            post '/update_task/:task_id', action: :update_task, as: :update_task

            post :create_recipe
            post '/update_recipe/:id', action: :update_recipe, as: :update_recipe
            post 'create_task_recipe_direction/:task_recipe_id', action: :create_task_recipe_direction, as: :create_task_recipe_direction
            post 'associate_recipe_to_form/:task_recipe_id', action: :associate_recipe_to_form, as: :associate_recipe_to_form

            get 'view_automated_campaign/:id', action: :view_automated_campaign, as: :view_automated_campaign
            post :create_automated_campaign
            post 'create_automated_campaign_step/:automated_campaign_id', action: :create_automated_campaign_step, as: :create_automated_campaign_step
            post 'associate_campaign_to_form/:automated_campaign_id', action: :associate_campaign_to_form, as: :associate_campaign_to_form
          end
        end
      end
    end
  end
end
