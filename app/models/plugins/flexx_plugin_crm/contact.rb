require 'aasm'

class Plugins::FlexxPluginCrm::Contact < ActiveRecord::Base
  include AASM

  after_destroy :remove_pending_tasks
  after_update :remove_pending_tasks, if: proc { |c| c.archived? }

  acts_as_taggable

  self.table_name = 'contacts'

  belongs_to :site, class_name: 'CamaleonCms::Site'
  belongs_to :cama_contact_form, class_name: 'Plugins::CamaContactForm::CamaContactForm'
  has_many :automated_campaign_jobs, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignJob', dependent: :destroy
  has_many :notes, class_name: 'Plugins::FlexxPluginCrm::Note', as: :parent, dependent: :destroy
  has_many :phonenumbers, class_name: 'Plugins::FlexxPluginCrm::Phonenumber', dependent: :destroy
  has_many :tasks, class_name: 'Plugins::FlexxPluginCrm::Task'
  has_many :messages, class_name: 'Plugins::FlexxPluginCrm::Message', dependent: :destroy
  has_many :contact_forms, class_name: 'Plugins::CamaContactForm::CamaContactForm', dependent: :destroy

  validates :email, presence: true, uniqueness: { scope: :site_id }

  scope :active, -> { where.not(sales_stage: :archived) }

  accepts_nested_attributes_for :phonenumbers, allow_destroy: true, reject_if: proc { |attributes| attributes['number'].blank? }

  aasm('sales_stage') do
    state :lead, initial: true
    state :pending, :prospect, :customer, :archived
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

  private

  def remove_pending_tasks
    tasks.where(aasm_state: :pending).destroy_all
  end
end
