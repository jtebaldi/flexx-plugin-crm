module Plugins::FlexxPluginCrm
  class ImportController < Plugins::FlexxPluginCrm::ApplicationController
    layout 'layouts/flexx_next_admin'

    def index; end

    def contacts
      CSV.foreach(params[:contacts].path, headers: true) do |r|
        current_site.contacts.find_or_create_by email: r['email'] do |c|
          c.attributes = r.to_hash
          c.birthday = Time.strptime r['birthday'], '%Y/%m/%d'
        end
      end
      flash[:notice] = 'Contacts imported.'
      redirect_to action: :index
    end
  end
end
