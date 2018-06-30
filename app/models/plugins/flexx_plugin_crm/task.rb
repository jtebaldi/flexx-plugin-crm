require 'aasm'

class Plugins::FlexxPluginCrm::Task < ActiveRecord::Base
  include AASM

  acts_as_taggable

  self.table_name = 'tasks'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :site, class_name: 'CamaleonCms::Site'

  has_many :notes, class_name: 'Plugins::FlexxPluginCrm::Note', as: :parent

  has_many :task_owners, class_name: 'Plugins::FlexxPluginCrm::TaskOwner'
  has_many :owners, class_name: 'CamaleonCms::User', through: :task_owners

  accepts_nested_attributes_for :notes
  accepts_nested_attributes_for :owners

  scope :done, -> { where(aasm_state: :done) }
  scope :due_today, -> { where(due_date: DateTime.now.beginning_of_day..DateTime.now.end_of_day) }
  scope :pending, -> { where(aasm_state: :pending) }
  scope :upcoming, -> { where('due_date > ?', DateTime.now.end_of_day) }

  aasm do
    state :pending, initial: true
    state :done
  end

  def updated_by_user
    CamaleonCms::User.find(updated_by)
  end

  def confirm
    self.confirmed_at = DateTime.now

    # TODO: use a system user to create an automatic note
    self.notes.new(details: "Task confirmed.", created_by: CamaleonCms::User.first)
  end

  def cancel
    # TODO: use a system user to create an automatic note
    self.notes.new(details: "Task cancelled.", created_by: CamaleonCms::User.first)
  end
end
