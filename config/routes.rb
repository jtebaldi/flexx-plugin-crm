Rails.application.routes.draw do
  scope PluginRoutes.system_info["relative_url_root"] do
    scope :admin, as: 'admin', path: PluginRoutes.system_info['admin_path_name'] do
      scope :next do
        get 'contact_card/:id', controller: 'plugins/flexx_plugin_crm/admin', action: :contact_card
        get 'contacts/:id/remove_contact_task/:task_id', controller: 'plugins/flexx_plugin_crm/admin', action: :remove_contact_task, as: :remove_contact_task
        post 'contacts/:id/update_contact_status', controller: 'plugins/flexx_plugin_crm/admin', action: :update_contact_status, as: :update_contact_status
        post 'contacts/:id/tasks', controller: 'plugins/flexx_plugin_crm/admin', action: :create_contact_task, as: :create_contact_task

        get 'task_card/:id(/:refresh_panel)', controller: 'plugins/flexx_plugin_crm/admin', action: :task_card, as: :task_card

        get   'recipe_card/:id', controller: 'plugins/flexx_plugin_crm/admin', action: :recipe_card
        post  'recipes/:id/forms', controller: 'plugins/flexx_plugin_crm/admin', action: :associate_recipe_to_form, as: :associate_recipe_to_form

        get 'list_tags', controller: 'plugins/flexx_plugin_crm/admin', action: :list_tags, as: :list_tags
        get 'list_contacts', controller: 'plugins/flexx_plugin_crm/admin', action: :list_contacts, as: :list_contacts

        resources :recipes, controller: 'plugins/flexx_plugin_crm/recipes' do
          get  :toggle
          post :create_direction
        end

        resources :tasks, controller: 'plugins/flexx_plugin_crm/tasks' do
          collection do
            post :defer_task
            post :send_task_confirmation
          end

          get  'task_owners/:refresh_panel', action: :task_owners, as: :task_owners
        end

        resources :contacts, controller: 'plugins/flexx_plugin_crm/contacts', except: [:edit] do
          get 'add_task_recipe/:task_recipe_id', action: :add_task_recipe, as: :add_task_recipe
        end

        resources :messages, controller: 'plugins/flexx_plugin_crm/messages', only: :index do
          collection do
            post :inbound
            post :status
            post :confirmation
            post :send_email_blast
            post :create_text_message
          end
        end

        resources :webhooks, controller: 'plugins/flexx_plugin_crm/webhooks', only: [] do
          collection do
            post 'inbound'
            post 'status'
            post 'confirmation'
            post 'sg_events'
          end
        end
      end

      namespace 'plugins' do
        namespace 'flexx_plugin_crm' do
          controller :admin do

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
