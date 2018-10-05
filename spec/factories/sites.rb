FactoryBot.define do
  factory :site, class: 'CamaleonCms::Site' do
    name { 'Test site' }
    # after :create do |site, _evaluator|
    #   create :automated_campaign, site: site
    # end
  end
end
