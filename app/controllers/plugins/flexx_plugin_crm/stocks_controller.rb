module Plugins::FlexxPluginCrm
  class StocksController < CamaleonCms::Apps::PluginsAdminController
    layout "layouts/flexx_next_admin"

    def index
      @stocks = current_site.stocks
    end
  end
end
