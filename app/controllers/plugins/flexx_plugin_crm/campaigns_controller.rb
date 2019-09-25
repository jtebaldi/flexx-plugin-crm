module Plugins::FlexxPluginCrm
  class CampaignsController < Plugins::FlexxPluginCrm::ApplicationController
    layout "layouts/flexx_next_admin"

    def index
      @active_campaigns = Array.new
      @paused_campaigns = Array.new
    end
  end
end
