module Plugins::FlexxPluginCrm
  class ContactsController < Plugins::FlexxPluginCrm::ApplicationController
    include Plugins::FlexxPluginCrm::Concerns::HasDynamicFields

    layout "layouts/flexx_next_admin"

    before_action :load_records, only: [:show, :update]

    def index
      @active_contacts = current_site.contacts.active.order('created_at desc', :first_name)
      @tags = current_site.owned_tags.order(:name)
    end

    def create
      new_contact = current_site.contacts.create!(contact_params)

      current_site.tag(new_contact, with: params[:contact][:tag_list], on: :tags)

      redirect_to action: :show, id: new_contact.id
    end

    def show; end

    def update
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

    def phone_validate
      phone = current_site.phonenumbers.where.not(
        contact_id: (params[:id] == 'new' ? nil : params[:id])
      ).find_by_number params[:number]

      if phone
        render json: { message: 'The phone number is already in use.' }
      else
        head :ok
      end
    end

    def with_email
      render json: current_site.contacts.active.map { |c| { name: "#{c.print_name} - #{c.email}", value: c.id } }
    end

    def with_mobile
      render json: current_site.contacts.joins(:phonenumbers).where(phonenumbers: { phone_type: 'mobile' }).map { |c| { name: "#{c.print_name}", value: c.id } }
    end

    private

    def load_records
      @contact = current_site.contacts.find(params[:id])
      @feed_activities = ActivityFeedService.list_activities(feed_name: 'contact', feed_id: @contact.id)
      @automated_campaigns = current_site.automated_campaigns.active
      @subscribed_campaigns = AutomatedCampaignJob.where(contact_id: @contact.id).pluck(:automated_campaign_id)
      @available_recipes = TaskRecipe.active.where(site_id: current_site.id).order(:title)
      @dynamic_fields = df_defaults + [['-', '']] + df_snippets
    end

    def contact_params
      p = params.require(:contact).permit(
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

      p[:created_by] = current_user.id

      if p[:phonenumbers_attributes].present?
        p[:phonenumbers_attributes].each do |row|
          next unless row[:number] && row[:number].empty?

          row[:_destroy] = 1
        end
      end

      p[:birthday] = Date.strptime(p[:birthday], '%m/%d/%Y').in_time_zone rescue nil
      p
    end
  end
end
