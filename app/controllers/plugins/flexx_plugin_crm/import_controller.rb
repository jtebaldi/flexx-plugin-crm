module Plugins::FlexxPluginCrm
  class ImportController < Plugins::FlexxPluginCrm::ApplicationController
    layout 'layouts/flexx_next_admin'

    def index; end

    def contacts
      ImportContactsService.import_csv(file: params[:contacts].path, site: current_site, user: current_user)

      flash[:notice] = 'Contacts imported.'
      redirect_to action: :index
    end
  end
end
