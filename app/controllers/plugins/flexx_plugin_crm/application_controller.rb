module Plugins::FlexxPluginCrm
  class ApplicationController < CamaleonCms::Apps::PluginsAdminController
    around_action :set_time_zone, if: :current_site

    private

    def set_time_zone(&block)
      timezone = current_site.timezone.blank? ? 'UTC' : current_site.timezone
      Time.use_zone(timezone, &block)
    end
  end
end
