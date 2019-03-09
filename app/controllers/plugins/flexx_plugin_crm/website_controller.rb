module Plugins::FlexxPluginCrm
  class WebsiteController < Plugins::FlexxPluginCrm::ApplicationController
    layout "layouts/flexx_next_admin"

    def index; end

    def new_page
      render :new_page, layout: 'contentbox'
    end
  end
end
