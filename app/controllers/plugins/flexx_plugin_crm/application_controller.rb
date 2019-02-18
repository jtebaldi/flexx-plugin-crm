module Plugins::FlexxPluginCrm
  class ApplicationController < CamaleonCms::Apps::PluginsAdminController
    around_action :set_time_zone, if: :current_site
    before_action :load_system_feed
    before_action :get_active_contacts

    private

    def set_time_zone(&block)
      timezone = current_site.timezone.blank? ? 'UTC' : current_site.timezone
      Time.use_zone(timezone, &block)
    end

    def load_system_feed
      @system_feed = ActivityFeedService.list_activities(feed_name: 'system', feed_id: current_site.id, limit: 30)
    end

    def get_active_contacts
      @active_contact_list = current_site.contacts.active.order(:first_name)
    end
  end
end
