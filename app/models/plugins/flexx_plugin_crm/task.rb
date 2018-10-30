require 'aasm'

class Plugins::FlexxPluginCrm::Task < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::HasUsers
  include AASM

  acts_as_taggable

  self.table_name = 'tasks'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :site, class_name: 'CamaleonCms::Site'

  has_many :notes, class_name: 'Plugins::FlexxPluginCrm::Note', as: :parent

  has_many :task_owners, class_name: 'Plugins::FlexxPluginCrm::TaskOwner'
  has_many :owners, class_name: user_class_name, through: :task_owners

  validates :due_date, presence: true

  before_validation do
    self.due_date = Time.now unless due_date
  end

  accepts_nested_attributes_for :notes
  accepts_nested_attributes_for :owners

  scope :done, -> { where(aasm_state: :done) }
  scope :due_today, -> { where(due_date: Time.now.beginning_of_day..Time.now.end_of_day) }
  scope :pending, -> { where(aasm_state: :pending) }
  scope :upcoming, -> { where('due_date > ?', Time.now.end_of_day) }
  scope :old, -> { where('due_date < ?', Time.now.beginning_of_day) }
  scope :done_today, -> { where(updated_at: Time.now.beginning_of_day..Time.now.end_of_day) }

  aasm do
    state :pending, initial: true
    state :done
  end

  def updated_by_user
    user_class.find(updated_by)
  end

  def confirm
    self.confirmed_at = Time.now

    self.notes.new(details: "Task confirmed.")
  end

  def cancel
    self.notes.new(details: "Task cancelled.")
  end
end
