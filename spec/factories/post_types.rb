FactoryBot.define do
  factory :post_type, class: 'CamaleonCms::PostType' do
    name { 'Test post type' }
    site
  end
end
