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

    def destroy
      current_site.automated_campaigns.find(params[:id]).update!(
        archived: true,
        archived_by: current_user.id,
        archived_at: Time.current
      )

      redirect_to action: :index
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
      current_site.automated_campaigns.find(params[:campaign_id]).steps.find(params[:id]).destroy
      redirect_to admin_campaign_path(params[:campaign_id])
    end

    def associate_form
      campaign = current_site.automated_campaigns.find(params[:campaign_id])
      campaign.cama_contact_forms.clear
      campaign.cama_contact_forms << current_site.contact_forms.where(id: params[:campaign][:cama_contact_form_ids])

      head :ok
    end

    def card
      @campaign = current_site.automated_campaigns.find(params[:campaign_id])

      render partial: "card"
    end

    def toggle
      @campaign = current_site.automated_campaigns.find(params[:campaign_id])

      @campaign.update(
        paused: !@campaign.paused,
        paused_by: !@campaign.paused ? current_user.id : nil,
        paused_at: !@campaign.paused ? Time.current : nil)

      respond_to do |format|
        format.js
      end
    end

    def subscribe
      @contact = current_site.contacts.find(params[:contact_id])
      campaign = current_site.automated_campaigns.find(params[:campaign_id])

      AutomatedCampaignService.apply_campaign(contact: @contact, campaign: campaign)

      @automated_campaigns = current_site.automated_campaigns.active
      @subscribed_campaigns = @contact.subscribed_campaigns

      render partial: 'update_campaigns_list'
    end

    def remove
      @contact = current_site.contacts.find(params[:contact_id])
      campaign = current_site.automated_campaigns.find(params[:campaign_id])

      campaign.remove(contact: @contact, deleted_by: current_user)

      @automated_campaigns = current_site.automated_campaigns.active
      @subscribed_campaigns = @contact.subscribed_campaigns

      if params[:head_only].present?
        head :ok
      else
        render partial: 'update_campaigns_list'
      end
    end

    def subscribers
      respond_to do |format|
        format.json {
          @subscribers = current_site.automated_campaigns.find(params[:campaign_id]).subscriptions.includes(:contact)

          render json: (@subscribers.map do |s|
            ac = s.contact
            {
              id: ac.id,
              initials: ac.initials,
              printName: ac.print_name,
              lastName: ac.last_name,
              createdDate: s.created_at.strftime('%b, %d %Y'),
              salesStage: ac.sales_stage.capitalize,
              salesStageClass: ac.sales_stage,
              pendingTasksClass: ('text-info' if ac.tasks.length > 0),
              pendingTasks: case ac.tasks.length
                            when 0
                              'No pending tasks'
                            when 1
                              '1 pending task'
                            else
                              "#{ac.tasks.length} pending tasks"
                            end,
              tags: ac.tags,
              subscriptionStatus: s.aasm_state.humanize,
              nextStep: s.running? ? s.next_step.campaign_step.name : ''
            }
          end)
        }
       end
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
