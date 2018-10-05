FactoryBot.define do
  factory :email_recipient, class: 'Plugins::FlexxPluginCrm::EmailRecipient' do
    status { 'to_send' }

    sequence :to do |n|
      "test#{n}@mail.net"
    end
  end
end
