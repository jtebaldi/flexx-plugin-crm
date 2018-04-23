require 'aasm'

class Plugins::FlexxPluginCrm::Task < ActiveRecord::Base
  include AASM

  self.table_name = 'tasks'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :site, class_name: 'CamaleonCms::Site'

  has_many :notes, class_name: 'Plugins::FlexxPluginCrm::Note', as: :parent

  accepts_nested_attributes_for :notes

  scope :pending, -> { where(aasm_state: :pending) }
  scope :done, -> { where(aasm_state: :done) }

  aasm do
    state :pending, initial: true
    state :done
  end

  def updated_by_user
    CamaleonCms::User.find(updated_by)
  end
end
