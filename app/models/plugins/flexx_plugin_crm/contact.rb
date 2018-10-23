require 'aasm'

class Plugins::FlexxPluginCrm::Contact < ActiveRecord::Base
  include AASM

  acts_as_taggable

  self.table_name = 'contacts'

  belongs_to :site, class_name: 'CamaleonCms::Site'
  belongs_to :cama_contact_form, class_name: 'Plugins::CamaContactForm::CamaContactForm'
  has_many :automated_campaign_jobs, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignJob'
  has_many :notes, class_name: 'Plugins::FlexxPluginCrm::Note', as: :parent
  has_many :phonenumbers, class_name: 'Plugins::FlexxPluginCrm::Phonenumber'
  has_many :tasks, class_name: 'Plugins::FlexxPluginCrm::Task'
  has_many :messages, class_name: 'Plugins::FlexxPluginCrm::Message'

  scope :active, -> { where.not(sales_stage: :archived) }

  accepts_nested_attributes_for :phonenumbers

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
    elsif email
      "#{email[0]}#{email[1]}"
    else
      'NP'
    end

    result.upcase
  end

  def pending_tasks_count
    tasks.pending.count
  end
end
