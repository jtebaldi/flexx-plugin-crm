module Plugins::FlexxPluginCrm
  class SettingsController < Plugins::FlexxPluginCrm::ApplicationController
    layout 'flexx_next_admin'
    before_action :set_vars, only: %i[index update]

    def index
      case params[:tab].to_s
      when 'profile'
        @settings_class = ''
        @profile_class = ' active'
      else
        @settings_class = ' active'
        @profile_class = ''
      end
    end

    def update
      unless current_site.update(timezone: params[:site][:timezone]) && @business_email.update(value: params[:business_email])
        flash.now[:alert] = 'Settings update error.'
      else
        flash.now[:notice] = 'Settings were updated successfully.'
      end
    end

    def profile_update
      r = { user: current_user }; hooks_run('user_update', r)
      if current_user.update(user_params)
        current_user.set_metas(params[:meta]) if params[:meta].present?
        current_user.set_field_values(params[:field_options])
        r = { user: current_user, message: t('camaleon_cms.admin.users.message.updated'), params: params }; hooks_run('user_after_edited', r)
        flash.now[:notice] = r[:message]
        r = { user: current_user }; hooks_run('user_updated', r)
        # if cama_current_user.id == current_user.id
        #   redirect_to admin_settings_path
        # else
        #   redirect_to action: :index
        # end
      else
        flash.now[:lert] = current_user.errors.messages
      end
      render :update
    end

    def password_update
      unless current_user.valid_password? params[:old_password]
        flash.now[:alert] = 'Old password is invalid.'
        return
      end

      if current_user.update(password_params)
        bypass_sign_in current_user
        flash.now[:notice] = 'Pasword has been updated successfully.'
      else
        flash.now[:alert] = current_user.errors.messages
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

    def password_params
      params.require(:usr).permit(:password, :password_confirmation)
    end
  end
end
