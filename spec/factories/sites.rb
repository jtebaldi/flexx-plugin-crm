FactoryBot.define do
  factory :site, class: 'CamaleonCms::Site' do
    name { 'Test site' }
    slug { 'example.com' }

    after :create do |site, evaluator|
    #   create :term_taxonomy, name: site.name, taxonomy: 'site', slug: site.slug, parent: site
    #   create :automated_campaign, site: site
      create :plugin, site: site, name: 'flexx_plugin_crm', term_group: 1
    end
  end
end
