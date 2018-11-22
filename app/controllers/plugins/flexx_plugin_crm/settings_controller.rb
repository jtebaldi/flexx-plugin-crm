module Plugins::FlexxPluginCrm
  class SettingsController < CamaleonCms::Apps::PluginsAdminController
    layout 'flexx_next_admin'
    before_action :set_business_email

    def index; end

    def update
      r = { user: current_user }; hooks_run('user_update', r)
      if current_user.update(user_params)
        @business_email.update value: params[:business_email]
        current_user.set_metas(params[:meta]) if params[:meta].present?
        current_user.set_field_values(params[:field_options])
        r = { user: current_user, message: t('camaleon_cms.admin.users.message.updated'), params: params }; hooks_run('user_after_edited', r)
        flash[:notice] = r[:message]
        r = { user: current_user }; hooks_run('user_updated', r)
        if cama_current_user.id == current_user.id
          redirect_to admin_settings_path
        else
          redirect_to action: :index
        end
      else
        render 'index'
      end
    end

    private

    def set_business_email
      @business_email = current_site.custom_field_values.find_by_custom_field_slug 'business_email'
    end

    def user_params
      parameters = params.require(:user)
      # if cama_current_user.role_grantor?(@user)
      #   parameters.permit(:username, :email, :role, :first_name, :last_name)
      # else
      parameters.permit(:username, :email, :first_name, :last_name)
      # end
    end
  end
end
