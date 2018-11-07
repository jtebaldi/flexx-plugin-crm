FactoryBot.define do
  factory :user, class: 'CamaleonCms::User' do
    username { 'Test user' }
    email { 'testuser@mail.net' }
    password { '12345678' }
  end
end
