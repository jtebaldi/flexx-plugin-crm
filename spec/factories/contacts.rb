FactoryBot.define do
  factory :contact, class: 'Plugins::FlexxPluginCrm::Contact' do
    email { 'test@email.net' }
  end
end
