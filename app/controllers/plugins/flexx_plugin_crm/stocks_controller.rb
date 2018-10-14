module Plugins::FlexxPluginCrm
  class StocksController < CamaleonCms::Apps::PluginsAdminController
    include Plugins::FlexxPluginCrm::Concerns::HasDynamicFields

    layout "layouts/flexx_next_admin"

    def index
      @stocks = current_site.stocks
      @dynamic_fields = {
        flexxdynamicfields: df_defaults + [['-', '']] + df_snippets
      }.to_json
    end

    def new
      case params[:stock_type]
      when 'rich_text'
        render partial: 'rich_text', locals: { stock: Plugins::FlexxPluginCrm::Stock.rich_texts.new }
      when 'html'
      else
        render partial: 'snippet', locals: { stock: Plugins::FlexxPluginCrm::Stock.snippets.new }
      end
    end

    def create
      @stock = current_site.stocks.create!(stock_params.merge(created_by: current_user.id))

      @stocks = current_site.stocks
    end

    def show
      stock = current_site.stocks.find(params[:id])

      render partial: stock.stock_type, locals: { stock: stock }
    end

    def update
      @stock = current_site.stocks.find(params[:id])

      @stock.update(stock_params.merge(updated_by: current_user.id))

      @stocks = current_site.stocks
    end

    private

    def stock_params
      params.require(:stock).permit(:id, :stock_type, :name, :label, :description, :contents, metadata: [:subject])
    end
  end
end
