module Plugins::FlexxPluginCrm
  class CampaignsController < Plugins::FlexxPluginCrm::ApplicationController
    layout "layouts/flexx_next_admin"

    def index
      @active_campaigns = current_site.automated_campaigns.active
      @paused_campaigns = current_site.automated_campaigns.paused
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
      @campaign = current_site.automated_campaigns.find(params[:campaign_id])

      params[:campaign_step].merge!(created_by: current_user.id)

      @campaign.steps.create!(campaign_step_params)

      respond_to do |format|
        format.js
      end
    end

    def destroy_step
    end

    def associate_form
    end

    def card
      @campaign = current_site.automated_campaigns.find(params[:campaign_id])

      render partial: "card"
    end

    private

    def campaign_params
      params.require(:campaign).permit(:name, :description, :created_by)
    end

    def campaign_step_params
      params.require(:campaign_step).permit(:due_on_value, :due_on_unit, :name, :stock_id, :created_by)
    end
  end
end
