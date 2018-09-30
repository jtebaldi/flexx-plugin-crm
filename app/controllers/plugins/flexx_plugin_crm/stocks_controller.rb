module Plugins::FlexxPluginCrm
  class StocksController < CamaleonCms::Apps::PluginsAdminController
    layout "layouts/flexx_next_admin"

    def index
      @stocks = current_site.stocks
      @new_text_snippet = current_site.stocks.text_snippets.new
      @new_rich_text_snippet = current_site.stocks.rich_text_snippets.new
    end

    def create
      current_site.stocks.create!(stock_params.merge(created_by: current_user.id))
    end

    private

    def stock_params
      params.require(:stock).permit(:id, :stock_type, :name, :label, :description, :contents)
    end
  end
end
