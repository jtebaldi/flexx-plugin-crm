Rails.application.routes.draw do
  scope PluginRoutes.system_info["relative_url_root"] do
    scope :admin, as: 'admin', path: PluginRoutes.system_info['admin_path_name'] do
      scope :next do
        get 'contacts/:id/remove_contact_task/:task_id', controller: 'plugins/flexx_plugin_crm/admin', action: :remove_contact_task, as: :remove_contact_task
        post 'contacts/:id/update_contact_status', controller: 'plugins/flexx_plugin_crm/admin', action: :update_contact_status, as: :update_contact_status
        post 'contacts/:id/tasks', controller: 'plugins/flexx_plugin_crm/admin', action: :create_contact_task, as: :create_contact_task

        get 'task_card/:id(/:refresh_panel)', controller: 'plugins/flexx_plugin_crm/admin', action: :task_card, as: :task_card

        get   'recipe_card/:id', controller: 'plugins/flexx_plugin_crm/admin', action: :recipe_card
        post  'recipes/:id/forms', controller: 'plugins/flexx_plugin_crm/admin', action: :associate_recipe_to_form, as: :associate_recipe_to_form

        get 'list_tags', controller: 'plugins/flexx_plugin_crm/admin', action: :list_tags, as: :list_tags

        controller 'plugins/flexx_plugin_crm/admin' do
          get :from_form
          delete :delete_form
        end

        scope :engage, controller: 'plugins/flexx_plugin_crm/engage' do
          get '/', action: :index
        end

        scope :website, controller: 'plugins/flexx_plugin_crm/website' do
          root action: :index
          get :new_page
        end

        resources :recipes, controller: 'plugins/flexx_plugin_crm/recipes' do
          get  :toggle
          post :create_direction
          delete 'destroy_direction/:id', action: :destroy_direction, as: :destroy_direction
        end

        resources :tasks, controller: 'plugins/flexx_plugin_crm/tasks' do
          collection do
            get 'stocks/:id', action: :stock_card, as: :stock_card
            post :create_stock
            post :defer_task
            post :send_task_confirmation
            patch :update_note
            patch 'stocks/:id', action: :update_stock, as: :update_stock
            delete :delete_note
            delete 'stocks/:id', action: :delete_stock, as: :delete_stock
          end

          post :create_note, on: :member

          get 'task_owners/:refresh_panel', action: :task_owners, as: :task_owners
        end

        resources :contacts, controller: 'plugins/flexx_plugin_crm/contacts', except: [:edit] do
          get 'add_task_recipe/:task_recipe_id', action: :add_task_recipe, as: :add_task_recipe

          member do
            get :email_validate
            get :phone_validate
            get :card
          end

          collection do
            get :with_email
            get :with_mobile
            post :mass_action
          end
        end

        resources :messages, controller: 'plugins/flexx_plugin_crm/messages', only: [] do
          collection do
            get :emails
            get :sms
            get :new_email
            get :new_sms
            post :inbound
            post :status
            post :confirmation
            post :create_email
            post :create_message
            post :create_message_blast
            post :send_test_email
          end

          member do
            get :edit_email
            patch :update_email
            delete :delete_email
          end
        end

        resources :conversations, controller: 'plugins/flexx_plugin_crm/conversations', only: [:index, :show, :create] do
          collection do
            patch :mark_contact_messages_read
          end
        end

        resources :stocks, controller: 'plugins/flexx_plugin_crm/stocks'

        resources :webhooks, controller: 'plugins/flexx_plugin_crm/webhooks', only: [] do
          collection do
            post :twilio_inbound
            post :twilio_status
            post :twilio_confirmation
            post :sendgrid_events
            post :sendgrid_parse
            post :zap_new_contact
          end
        end

        resources :dashboard, controller: 'plugins/flexx_plugin_crm/dashboard', only: :index do
          get :from_form, on: :collection
        end

        resources :settings, controller: 'plugins/flexx_plugin_crm/settings' do
          get :email_validate, on: :collection
          get :username_validate, on: :collection
          patch :update, on: :collection
          patch :profile_update, on: :collection
          patch :password_update, on: :collection
          get '/(:tab)', action: :index, on: :collection, as: :index
        end

        scope :import, controller: 'plugins/flexx_plugin_crm/import' do
          get '/', action: :index, as: :import
          post :contacts, as: :import_contacts
        end

        resources :forms, controller: 'plugins/flexx_plugin_crm/forms', only: [:index, :edit, :update]
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
