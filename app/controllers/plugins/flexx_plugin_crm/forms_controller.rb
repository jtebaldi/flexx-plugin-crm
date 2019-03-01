module Plugins::FlexxPluginCrm
  class FormsController < Plugins::FlexxPluginCrm::ApplicationController
    layout "layouts/flexx_next_admin"

    def index
      @forms = current_site.contact_forms.where(parent_id: nil).order(:name)
    end

    def edit; end
  end
end
