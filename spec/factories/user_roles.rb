FactoryBot.define do
  factory :user_role, class: 'CamaleonCms::UserRole' do
    taxonomy { 'user_roles' }
    description { 'Default roles admin' }
    slug { 'admin' }
  end
end
