FactoryBot.define do
  factory :automated_campaign_job, class: 'Plugins::FlexxPluginCrm::AutomatedCampaignJob' do
    site
    automated_campaign
    contact
    message { 'Test message' }
    send_to { 'Mail' }
    send_at { Time.current }
    status_changed_at { Time.current }
  end
end
