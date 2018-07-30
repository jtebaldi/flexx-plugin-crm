Rails.application.routes.draw do
  scope PluginRoutes.system_info["relative_url_root"] do
    scope :admin, as: 'admin', path: PluginRoutes.system_info['admin_path_name'] do
      scope :next do
        get 'contact_card/:id', controller: 'plugins/flexx_plugin_crm/admin', action: :contact_card
        get 'contacts/:id', controller: 'plugins/flexx_plugin_crm/admin', action: :view_contact, as: :view_contact
        get 'contacts/:id/remove_contact_task/:task_id', controller: 'plugins/flexx_plugin_crm/admin', action: :remove_contact_task, as: :remove_contact_task
        post 'contacts/:id/update_contact_status', controller: 'plugins/flexx_plugin_crm/admin', action: :update_contact_status, as: :update_contact_status
        post 'contacts/:id/tasks', controller: 'plugins/flexx_plugin_crm/admin', action: :create_contact_task, as: :create_contact_task
        post 'contacts/:id/messages', controller: 'plugins/flexx_plugin_crm/admin', action: :create_contact_message, as: :create_contact_message

        get 'task_card/:id/:refresh_panel', controller: 'plugins/flexx_plugin_crm/admin', action: :task_card, as: :task_card

        get   :recipes, controller: 'plugins/flexx_plugin_crm/admin', action: :recipes
        get   'recipe_card/:id', controller: 'plugins/flexx_plugin_crm/admin', action: :recipe_card
        get   'recipes/:id', controller: 'plugins/flexx_plugin_crm/admin', action: :view_recipe, as: :view_recipe
        get   'toggle_recipe/:id', controller: 'plugins/flexx_plugin_crm/admin', action: :toggle_recipe, as: :toggle_recipe
        get   'recipes/:id/remove', controller: 'plugins/flexx_plugin_crm/admin', action: :remove_recipe, as: :remove_recipe
        post  :recipes, controller: 'plugins/flexx_plugin_crm/admin', action: :create_recipe, as: :create_recipe
        post  'recipes/:id/directions', controller: 'plugins/flexx_plugin_crm/admin', action: :create_recipe_direction, as: :create_recipe_direction
        post  'recipes/:id/forms', controller: 'plugins/flexx_plugin_crm/admin', action: :associate_recipe_to_form, as: :associate_recipe_to_form

        get 'list_tags', controller: 'plugins/flexx_plugin_crm/admin', action: :list_tags, as: :list_tags

        resources :tasks, controller: 'plugins/flexx_plugin_crm/tasks', only: [:index, :update] do
          collection do
            post :defer_task
            post :send_task_confirmation
          end

          get  'task_owners/:refresh_panel', action: :task_owners, as: :task_owners
        end

        resources :contacts, controller: 'plugins/flexx_plugin_crm/contacts', only: [:index, :create]

        resources :messages, controller: 'plugins/flexx_plugin_crm/messages' do
          collection do
            post 'inbound'
            post 'status'
            post 'confirmation'
            post 'send_email_blast'
          end
        end
      end

      namespace 'plugins' do
        namespace 'flexx_plugin_crm' do
          controller :admin do
            get :index
            get :settings
            post :save_settings

            get :new_contact
            post '/update_contact/:id', action: :update_contact, as: :update_contact

            post '/create_task/:contact_id', action: :create_task, as: :create_task
            post '/update_task/:task_id', action: :update_task, as: :update_task

            post '/update_recipe/:id', action: :update_recipe, as: :update_recipe

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
