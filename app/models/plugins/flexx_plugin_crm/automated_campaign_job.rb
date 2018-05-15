require 'aasm'

class Plugins::FlexxPluginCrm::AutomatedCampaignJob < ActiveRecord::Base
  include AASM

  self.table_name = 'automated_campaign_jobs'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'

  aasm('status') do
    state :queued, initial: true
    state :running, :finished, :failed
  end

  scope :queue, -> { where(['status = ? AND send_at <= ?', :queued, DateTime.now + 6.hours])  }
end
