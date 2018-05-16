require 'aasm'

class Plugins::FlexxPluginCrm::Contact < ActiveRecord::Base
  include AASM

  self.table_name = 'contacts'

  belongs_to :cama_contact_form, class_name: 'Plugins::CamaContactForm::CamaContactForm'
  has_many :automated_campaign_jobs, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignJob'
  has_many :notes, class_name: 'Plugins::FlexxPluginCrm::Note', as: :parent
  has_many :tasks, class_name: 'Plugins::FlexxPluginCrm::Task'

  scope :active, -> { where.not(sales_stage: :archived) }

  after_commit :create_sendgrid_record, on: :create
  after_commit :update_sendgrid_record, on: :update

  aasm('sales_stage') do
    state :pending, initial: true
    state :lead, :prospect, :customer, :archived
  end

  def print_name
    result = [first_name, last_name].join(' ')
    result.blank? ? email : result
  end

  def initials
    result = if first_name.present? && last_name.present?
      "#{first_name[0]}#{last_name[0]}"
    else
      "#{email[0]}#{email[1]}"
    end

    result.upcase
  end

  def pending_tasks_count
    tasks.pending.count
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
