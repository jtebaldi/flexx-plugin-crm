require 'aasm'

class Plugins::FlexxPluginCrm::Contact < ActiveRecord::Base
  include AASM

  self.table_name = 'contacts'

  has_many :tasks, class_name: 'Plugins::FlexxPluginCrm::Task'

  scope :active, -> { where.not(sales_stage: :archived) }

  after_commit :create_sendgrid_record, on: :create
  after_commit :update_sendgrid_record, on: :update

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

    update_column(:sendgrid_id, sg_id)
  end

  def update_sendgrid_record
    details = [{
      email: email,
      first_name: first_name,
      last_name: last_name,
      sales_stage: sales_stage
    }]

    if previous_changes.keys.include?("email")
      sg_id = SendgridService.new.create_contact(contact_details: details)

      update_column(:sendgrid_id, sg_id)
    else
      SendgridService.new.update_contact(contact_details: details)
    end
  end
end
