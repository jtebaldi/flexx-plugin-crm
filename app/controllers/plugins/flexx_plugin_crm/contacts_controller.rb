module Plugins::FlexxPluginCrm
  class ContactsController < CamaleonCms::Apps::PluginsAdminController
    layout "layouts/flexx_next_admin"

    def index
      @active_contacts = current_site.contacts.active.order(:first_name, :email)
    end

    def create
      new_contact = current_site.contacts.create!(contact_params)

      current_site.tag(new_contact, with: params[:contact][:tag_list], on: :tags)

      redirect_to controller: :admin, action: :view_contact, id: new_contact.id
    end

    private

    def contact_params
      params[:contact].merge!(created_by: current_user.id)

      params.require(:contact).permit(
        :sales_stage,
        :first_name,
        :last_name,
        :email,
        :source,
        :highlights,
        :created_by,
        phonenumbers_attributes: [:number, :phone_type]
      )
    end
  end
end
