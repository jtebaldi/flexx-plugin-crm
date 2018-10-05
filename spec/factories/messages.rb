FactoryBot.define do
  factory :message, class: 'Plugins::FlexxPluginCrm::Message' do
    site
    contact

    trait :to_send do
      status { 'to_send' }
    end

    factory :message_to_send, traits: [:to_send]
  end
end
