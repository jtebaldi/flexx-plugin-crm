require 'csv'

module Plugins::FlexxPluginCrm
  class ImportController < Plugins::FlexxPluginCrm::ApplicationController
    layout 'layouts/flexx_next_admin'

    def index; end

    def contacts
      CSV.foreach(params[:contacts].path, headers: true) do |r|
        contact = current_site.contacts.find_or_create_by email: r['email'] do |c|
          c.attributes = r.to_hash.except('phonenumber')
          c.birthday = Time.strptime r['birthday'], '%Y/%m/%d' if r['birthday']
          c.created_by = current_user.id
        end

        if r['phonenumber']
          number = if r['pnonenumber'] !~ /^\+/ && r['phonenumber'].length == 10
                     '+1' + r['phonenumber']
                   else
                     r['phonenumber']
                   end

          contact.phonenumbers.find_or_create_by number: number do |p|
            p.site = current_site
          end
        end
      end
      flash[:notice] = 'Contacts imported.'
      redirect_to action: :index
    end
  end
end
