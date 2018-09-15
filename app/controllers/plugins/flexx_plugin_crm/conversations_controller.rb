module Plugins::FlexxPluginCrm
  class ConversationsController < CamaleonCms::Apps::PluginsAdminController
    layout "layouts/flexx_next_admin"

    def index
      @contact_ids = Message.all.select(:contact_id).
        where.not(contact_id: nil).
        group(:contact_id).
        order("MAX(created_at) DESC")
    end

    def show
      @contact = current_site.contacts.find(params[:id])

      respond_to do |format|
        format.js
      end
    end
  end
end
