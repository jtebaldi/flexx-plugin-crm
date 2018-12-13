module Plugins::FlexxPluginCrm
  class ConversationsController < Plugins::FlexxPluginCrm::ApplicationController
    layout "layouts/flexx_next_admin"
    include Plugins::FlexxPluginCrm::Concerns::HasDynamicFields

    def index
      @contact_ids = current_site.messages.select(:contact_id).
        where.not(contact_id: nil).
        group(:contact_id).
        order("MAX(created_at) DESC")

      @dynamic_fields = df_defaults + [['-', '']] + df_snippets

      unless @contact_ids.empty?
        @first_contact = Contact.find_by(id: @contact_ids.first.contact_id)
        MessageBlastService.mark_contact_messages_read(contact: @first_contact)
      end

      @snippets = current_site.stocks.snippets.order(:name)
    end

    def show
      @contact = current_site.contacts.find(params[:id])
      @dynamic_fields = df_defaults + [['-', '']] + df_snippets

      MessageBlastService.mark_contact_messages_read(contact: @contact)

      respond_to do |format|
        format.js
      end
    end
  end
end
