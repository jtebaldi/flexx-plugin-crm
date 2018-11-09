require 'aasm'

class Plugins::FlexxPluginCrm::AutomatedCampaignJob < ActiveRecord::Base
  include AASM

  self.table_name = 'automated_campaign_jobs'

  belongs_to :contact, class_name: 'Plugins::FlexxPluginCrm::Contact'
  belongs_to :site, class_name: 'CamaleonCms::Site'
  belongs_to :automated_campaign, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaign'
  belongs_to :automated_campaign_step, class_name: 'Plugins::FlexxPluginCrm::AutomatedCampaignStep'

  aasm('status') do
    state :queued, initial: true
    state :running, :finished, :failed
  end

  scope :queue, -> { where(['status = ? AND send_at <= ?', :queued, Time.current + 6.hours])  }
end
