FactoryBot.define do
  factory :email, class: 'Plugins::FlexxPluginCrm::Email' do
    from { 'info@mail.net' }
    subject { 'Test email subject' }
    body { 'Test email body' }
    aasm_state { 'scheduled' }
    send_at { Time.current }

    transient do
      recipients_count { 4 }
    end

    trait :recipients do
      after :create do |email, eavaluator|
        create_list :email_recipient_with_contact, eavaluator.recipients_count, email: email
      end
    end

    trait :with_site { site }
  end
end
