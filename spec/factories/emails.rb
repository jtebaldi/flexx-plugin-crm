FactoryBot.define do
  factory :email, class: 'Plugins::FlexxPluginCrm::Email' do
    site
    subject { 'Test email subject' }
    body { 'Test email body' }
    aasm_state { 'to_send' }
    send_at { Time.now }

    transient do
      recipients_count { 4 }
    end

    after :create do |email, eavaluator|
      create_list :email_recipient, eavaluator.recipients_count, email: email
    end
  end
end
