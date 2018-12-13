FactoryBot.define do
  factory :message, class: 'Plugins::FlexxPluginCrm::Message' do
    site
    contact
    from_number { '123456789' }
    to_number { '987654321' }
    message { 'test message' }
    send_at { 1.hour.ago }

    trait :scheduled do
      aasm_state { 'scheduled' }
    end

    trait :done do
      aasm_state { 'sent' }
    end

    trait :received do
      status { 'received' }
    end

    factory :message_to_send, traits: [:scheduled]
  end
end
