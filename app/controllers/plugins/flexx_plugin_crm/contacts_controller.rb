module Plugins::FlexxPluginCrm
  class ContactsController < Plugins::FlexxPluginCrm::ApplicationController
    include Plugins::FlexxPluginCrm::Concerns::HasDynamicFields

    layout "layouts/flexx_next_admin"

    def index
      @active_contacts = current_site.contacts.active.order('created_at desc', :first_name)
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
      @available_recipes = TaskRecipe.active.where(site_id: current_site.id).order(:title)
      @dynamic_fields = {
        flexxdynamicfields: df_defaults + [['-', '']] + df_snippets
      }.to_json
    end

    def update
      @contact = current_site.contacts.find(params[:id])

      params[:contact].merge!(updated_by: current_user.id)

      if @contact.update(contact_params)
        current_site.tag(@contact, with: params[:contact][:tag_list], on: :tags)
        redirect_to action: :show, id: params[:id]
      else
        render :show
      end
    end

    def add_task_recipe
      contact = current_site.contacts.find(params[:contact_id])
      recipe = TaskRecipe.find(params[:task_recipe_id])

      TaskRecipeService.apply_recipe(contact: contact, recipe: recipe)

      redirect_to action: :show, id: contact.id
    end

    def email_validate
      contact = current_site.contacts.where.not(
        id: (params[:id] == 'new' ? nil : params[:id])
      ).find_by_email(params[:contact][:email])

      if contact
        message = if contact.archived?
                    'This email address is currently attached to an archived contact.'
                  else
                    'The email is already in use.'
                  end
        Rack::Utils::HTTP_STATUS_CODES[400] = message
        Puma::HTTP_STATUS_CODES[400] = message if defined? Puma
        head 400
      else
        head :ok
      end
    end

    private

    def contact_params
      if params[:contact][:phonenumbers_attributes].present?
        params[:contact][:phonenumbers_attributes].each do |row|
          params[:contact][:phonenumbers_attributes].delete(row) if row[:number].empty?
        end
      end

      params[:contact][:birthday] = Date.strptime(params[:contact][:birthday], '%m/%d/%Y').in_time_zone rescue nil

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
