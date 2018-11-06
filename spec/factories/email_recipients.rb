FactoryBot.define do
  factory :email_recipient, class: 'Plugins::FlexxPluginCrm::EmailRecipient' do
    sequence :to do |n|
      "test#{n}@mail.net"
    end

    trait :with_contact do
      association :contact, factory: :contact
    end

    factory :email_recipient_with_contact, traits: [:with_contact]
  end
end
