module Plugins::FlexxPluginCrm
  class DashboardController < CamaleonCms::CamaleonController
    layout 'flexx_next_admin'

    def index
      @active_contacts = current_site.contacts.active
      @todays_tasks = current_site.tasks.pending.due_today.order('due_date asc').includes(:contact, :owners)
      @todays_completed_tasks = current_site.tasks.done.done_today.order('updated_at desc').includes(:contact, :owners)
    end

    def settings
    end

    def crm
    end

    def media
    end

    def messaging
    end

    def conversations_email
    end

    def conversations_text
    end

    def gyms
    end

    def website
    end

    def stock
    end

    def stock_new
    end

    def from_form
      @contact = Plugins::FlexxPluginCrm::Contact.find params[:contact_id]
      render layout: false
    end
  end
end
