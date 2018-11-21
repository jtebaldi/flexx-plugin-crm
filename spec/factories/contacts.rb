FactoryBot.define do
  factory :contact, class: 'Plugins::FlexxPluginCrm::Contact' do
    sequence :email do |n|
      "test#{n}@email.net"
    end
  end
end
