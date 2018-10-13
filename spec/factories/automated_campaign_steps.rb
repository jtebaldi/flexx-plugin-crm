FactoryBot.define do
  factory :automated_campaign_step, class: 'Plugins::FlexxPluginCrm::AutomatedCampaignStep' do
    created_by { 1 }
    due_on_value { 1 }
    due_on_unit { 1 }
    name { 'Test campaign step' }
    message { 'Test campaign step message' }
  end
end
