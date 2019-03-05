module Plugins::FlexxPluginCrm
  class FormsController < Plugins::FlexxPluginCrm::ApplicationController
    layout "layouts/flexx_next_admin"

    def index
      @forms = current_site.contact_forms.where(parent_id: nil).order(:name)
    end

    def edit
      @form = current_site.contact_forms.find(params[:id])
    end

    def update
      @form = current_site.contact_forms.find(params[:id])
      settings = @form.settings.present? ? JSON.parse(@form.settings) : {}

      settings["railscf_mail"] = params[:railscf_mail]
      settings["railscf_twilio"] = params[:railscf_twilio]
      settings["railscf_redirect"] = params[:railscf_redirect]
      settings["railscf_webhook"] = params[:railscf_webhook]

      @form.update!(settings: settings.to_json)

      redirect_to action: :edit, id: @form.id
    end
  end
end
