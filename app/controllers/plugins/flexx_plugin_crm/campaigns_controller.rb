module Plugins::FlexxPluginCrm
  class CampaignsController < Plugins::FlexxPluginCrm::ApplicationController
    layout "layouts/flexx_next_admin"

    def index
      @active_campaigns = Array.new
      @paused_campaigns = Array.new
    end

    def create
      params[:campaign].merge!(created_by: current_user.id)

      new_campaign = current_site.automated_campaigns.create!(campaign_params)

      redirect_to action: :show, id: new_campaign.id
    end

    def show
      @campaign = current_site.automated_campaigns.find(params[:id])
      @available_contact_forms = current_site.
                                  contact_forms.
                                  select(:id, :name).
                                  where(parent_id: nil).
                                  order(:name)
    end

    def create_step
    end

    def destroy_step
    end

    def associate_form
    end

    private

    def campaign_params
      params.require(:campaign).permit(:name, :description, :created_by)
    end
  end
end
