require 'aasm'

class Plugins::FlexxPluginCrm::Contact < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include Plugins::FlexxPluginCrm::Concerns::ActivityFeed
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

  validates :email, uniqueness: { scope: :site_id }, if: Proc.new { |c| c.email.present? }

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

  def unanswered_message?
    messages.order(:created_at).last.status == 'received'
  end

  def created_by_user
    CamaleonCms::User.find_by(id: self.created_by)
  end

  def updated_by_user
    CamaleonCms::User.find_by(id: self.updated_by)
  end

  private

  def has_activity_record?
    self.id_changed? || self.sales_stage_changed?
  end

  def activity_record_params
    if self.id_changed?
      {
        feed_name: 'contact',
        feed_id: self.id,
        args: {
          actor: "User:#{self.created_by}",
          verb: 'contact_created',
          object: "Contact:#{self.id}",
          labels: {
            action: 'created',
            action_type: 'Contact',
            actor: self.created_by.present? ? self.created_by_user.print_name : 'Form'
          },
          message: "New contact created - #{self.print_name}",
          url: admin_contact_path(self.id),
          to: ["system:#{self.site_id}"]
        }
      }
    else
      {
        feed_name: 'contact',
        feed_id: self.id,
        args: {
          actor: "User:#{self.updated_by}",
          verb: 'updated',
          object: "Contact:#{self.id}",
          labels: {
            action: 'updated',
            action_type: "Status from #{self.sales_stage_was.humanize} to #{self.sales_stage.humanize}",
            actor: self.updated_by_user.print_name
          },
          message: "#{self.updated_by_user.print_name} updated #{self.print_name} status from #{self.sales_stage_was.humanize} to #{self.sales_stage.humanize}.",
          url: admin_contact_path(self.id),
          to: ["system:#{self.site_id}"]
        }
      }
    end
  end

  def remove_pending_tasks
    tasks.where(aasm_state: :pending).destroy_all
  end
end
