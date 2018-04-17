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

            post '/create_task/:id', action: :create_task, as: :create_task
          end
        end
      end
    end
  end
end
