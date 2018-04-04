require 'aasm'

class Plugins::FlexxPluginCrm::Contact < ActiveRecord::Base
  include AASM

  self.table_name = 'contacts'

  after_create :create_sendgrid_record

  aasm('sales_stage') do
    state :pending, initial: true
    state :lead, :prospect, :customer, :archived
  end

  private

  def create_sendgrid_record
    details = [{
      email: email,
      first_name: first_name,
      last_name: last_name,
      sales_stage: sales_stage
    }]

    sg_id = SendgridService.new.create_contact(contact_details: details)

    update(sendgrid_id: sg_id) if sg_id.present?
  end
end
