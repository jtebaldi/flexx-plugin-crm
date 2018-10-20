FactoryBot.define do
  factory :message, class: 'Plugins::FlexxPluginCrm::Message' do
    site
    contact
    send_at { Time.now }

    trait :scheduled do
      aasm_state { 'scheduled' }
    end

    factory :message_to_send, traits: [:scheduled]
  end
end
