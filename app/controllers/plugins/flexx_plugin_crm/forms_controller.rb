module Plugins::FlexxPluginCrm
  class FormsController < Plugins::FlexxPluginCrm::ApplicationController
    layout "layouts/flexx_next_admin"

    def index
      @forms = current_site.contact_forms.where(parent_id: nil).order(:name)
    end

    def edit
      @form = current_site.contact_forms.find(params[:id])
      values = JSON.parse(@form.value).to_sym
      @op_fields = values[:fields].select{ |field| relevant_field? field }
      @forms = current_site.contact_forms.where({parent_id: @form.id})
      # @forms = @forms.paginate(:page => params[:page], :per_page => 50)
    end

    def update
      @form = current_site.contact_forms.find(params[:id])
      settings = @form.settings.present? ? JSON.parse(@form.settings) : {}

      settings["railscf_mail"] = params[:railscf_mail]
      settings["railscf_twilio"] = params[:railscf_twilio]
      settings["railscf_redirect"] = params[:railscf_redirect]
      settings["railscf_webhook"] = params[:railscf_webhook]
      settings["railscf_response"] = params[:railscf_response]
      settings["railscf_tags"] = params[:railscf_tags]

      @form.update!(settings: settings.to_json)

      redirect_to action: :edit, id: @form.id
    end

    def relevant_field?(field)
      !%w(captcha recaptcha submit button stripe twilio).include? field[:field_type]
    end
  end
end
