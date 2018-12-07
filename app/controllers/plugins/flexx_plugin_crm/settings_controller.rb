module Plugins::FlexxPluginCrm
  class SettingsController < Plugins::FlexxPluginCrm::ApplicationController
    layout 'flexx_next_admin'
    before_action :set_vars, only: %i[index update]

    def index; end

    def update
      r = { user: current_user }; hooks_run('user_update', r)
      current_site.update timezone: params[:site][:timezone]
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

    def email_validate
      not_found = !CamaleonCms::User.where.not(id: current_user.id)
                                    .find_by_email(params[:user][:email])
      render json: not_found
    end

    def username_validate
      not_found = !CamaleonCms::User.where.not(id: current_user.id)
                                    .find_by_username(params[:user][:username])
      render json: not_found
    end

    private

    def set_vars
      @business_email = current_site.custom_field_values.find_by_custom_field_slug 'business_email'
      @twilio_number  = current_site.get_option('twilio_campaigns_number')
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
