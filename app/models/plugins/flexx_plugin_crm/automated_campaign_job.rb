require 'aasm'

class Plugins::FlexxPluginCrm::AutomatedCampaignJob < ActiveRecord::Base
  include AASM

  aasm('status') do
    state :queued, initial: true
    state :running, :finished, :failed
  end

  self.table_name = 'automated_campaign_jobs'
end
