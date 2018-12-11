module Plugins::FlexxPluginCrm
  class DashboardController < Plugins::FlexxPluginCrm::ApplicationController
    layout 'flexx_next_admin'

    def index
      @active_contacts = current_site.contacts.includes(cama_contact_form: :parent).active
      @todays_tasks = current_site.tasks.pending.due_today.order('due_date asc').includes(:contact, :owners)
      @todays_completed_tasks = current_site.tasks.done.done_today.order('updated_at desc').includes(:contact, :owners)
      @forms_completed = current_site.contact_forms.includes(:contact)
                                     .where.not(contacts: { id: nil, sales_stage: "archived" }, parent_id: nil)
                                     .order(created_at: :desc)
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
  end
end
