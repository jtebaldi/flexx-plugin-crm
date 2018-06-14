module Plugins::FlexxPluginCrm
  class ContactsController < CamaleonCms::Apps::PluginsAdminController
    layout "layouts/flexx_next_admin"

    def index
      @active_contacts = current_site.contacts.active.order(:first_name, :email)
    end

    def create
      new_contact = current_site.contacts.create!(contact_params)

      redirect_to controller: :admin, action: :view_contact, id: new_contact.id
    end

    private

    def contact_params
      params.require(:contact).permit(
        :sales_stage,
        :first_name,
        :last_name,
        :email,
        :source,
        :highlights,
        phonenumbers_attributes: [:number, :phone_type]
      )
    end
  end
end
