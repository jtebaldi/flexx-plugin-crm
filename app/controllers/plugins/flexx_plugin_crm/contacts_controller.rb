module Plugins::FlexxPluginCrm
  class ContactsController < CamaleonCms::Apps::PluginsAdminController
    layout "layouts/flexx_next_admin"

    def index
      @active_contacts = current_site.contacts.active.order(:first_name, :email)
    end

    def create
      new_contact = current_site.contacts.create!(contact_params)

      current_site.tag(new_contact, with: params[:contact][:tag_list], on: :tags)

      redirect_to action: :show, id: new_contact.id
    end

    def show
      @contact = current_site.contacts.find(params[:id])
      @automated_campaigns = current_site.automated_campaigns.active
      @subscribed_campaigns = AutomatedCampaignJob.where(contact_id: @contact.id).pluck(:automated_campaign_id)
      @available_recipes = TaskRecipe.active.order(:title)
    end

    def update
      contact = current_site.contacts.find(params[:id])

      params[:contact].merge!(updated_by: current_user.id)

      contact.update(contact_params)
      current_site.tag(contact, with: params[:contact][:tag_list], on: :tags)

      redirect_to action: :show, id: params[:id]
    end

    private

    def contact_params
      if params[:contact][:phonenumbers_attributes].present?
        params[:contact][:phonenumbers_attributes].each do |row|
          params[:contact][:phonenumbers_attributes].delete(row) if row[:number].empty?
        end
      end

      params[:contact][:birthday] = Date.strptime(params[:contact][:birthday], '%m/%d/%Y') rescue nil

      params[:contact].merge!(created_by: current_user.id)
      params.require(:contact).permit(
        :sales_stage,
        :first_name,
        :last_name,
        :email,
        :source,
        :highlights,
        :created_by,
        :address1,
        :address2,
        :city,
        :state,
        :country,
        :postal_code,
        :birthday,
        :updated_by,
        phonenumbers_attributes: [:id, :number, :phone_type]
      )
    end
  end
end
