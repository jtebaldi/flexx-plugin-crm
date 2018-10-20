FactoryBot.define do
  factory :automated_campaign, class: 'Plugins::FlexxPluginCrm::AutomatedCampaign' do
    site
    name { 'Test campaign' }
    after :create do |ac, _eval|
      acs = create :automated_campaign_step, automated_campaign: ac
      create :automated_campaign_job, automated_campaign: ac,
                                      automated_campaign_step: acs,
                                      site: ac.site
    end
  end
end
