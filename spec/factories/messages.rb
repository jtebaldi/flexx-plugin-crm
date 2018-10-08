FactoryBot.define do
  factory :message, class: 'Plugins::FlexxPluginCrm::Message' do
    site
    contact
    send_at { Time.now }

    trait :to_send do
      aasm_state { 'to_send' }
    end

    factory :message_to_send, traits: [:to_send]
  end
end
