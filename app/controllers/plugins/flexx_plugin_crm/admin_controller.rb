module Plugins::FlexxPluginCrm
  class AdminController < CamaleonCms::Apps::PluginsAdminController
    include Plugins::FlexxPluginCrm::MainHelper
    def index
      @active_contacts = current_site.contacts.active
    end

    def create_contact
      new_contact = current_site.contacts.create!(new_contact_params)

      redirect_to action: :view_contact, id: new_contact.id
    end

    def view_contact
      @contact = current_site.contacts.find(params[:id])
    end

    def update_contact
      current_site.contacts.find(params[:id]).update(contact_params)

      redirect_to action: :view_contact, id: params[:id]
    end

    def settings
      @available_contact_forms = current_site.contact_forms.select(:id, :name).where(parent_id: nil).as_json
      @available_lists = ContactsManagerService.new.contact_lists
    end

    def list_details
      @list_details = ContactsManagerService.new.list_details(id: params[:list_id])
    end

    # save values from settings form
    def save_settings
      @plugin.set_options(params[:options]) if params[:options].present? # save option values
      @plugin.set_metas(params[:metas]) if params[:metas].present? # save meta values
      @plugin.set_field_values(params[:field_options]) if params[:field_options].present? # save custom field values
      redirect_to url_for(action: :settings), notice: 'Settings Saved Successfully'
    end

    private

    def new_contact_params
      params.require(:new_contact).permit(:sales_stage, :first_name, :last_name, :email)
    end

    def contact_params
      params.require(:contact).permit(:sales_stage, :first_name, :last_name, :email)
    end
  end
end
