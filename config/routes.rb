Rails.application.routes.draw do

    scope PluginRoutes.system_info["relative_url_root"] do
      scope '(:locale)', locale: /#{PluginRoutes.all_locales}/, :defaults => {  } do
        # frontend
        namespace :plugins do
          namespace 'flexx_plugin_crm' do
            get 'index' => 'front#index'
          end
        end
      end

      #Admin Panel
      scope :admin, as: 'admin', path: PluginRoutes.system_info['admin_path_name'] do
        namespace 'plugins' do
          namespace 'flexx_plugin_crm' do
            controller :admin do
              get :index
              get :new_contact
              get :settings
              get '/view_contact/:id', action: :view_contact, as: :view_contact
              post :create_contact
              post :save_settings
              post '/update_contact/:id', action: :update_contact, as: :update_contact
            end
          end
        end
      end

      # main routes
      #scope 'flexx_plugin_crm', module: 'plugins/flexx_plugin_crm/', as: 'flexx_plugin_crm' do
      #  Here my routes for main routes
      #end
    end
  end
