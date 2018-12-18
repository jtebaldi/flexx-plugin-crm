module Plugins::FlexxPluginCrm::Concerns::HasDynamicFields
  extend ActiveSupport::Concern

  def df_defaults
    [
      ['E-mail', 'contact_email'],
      ['First Name', 'contact_first_name'],
      ['Last Name', 'contact_last_name']
    ]
  end

  def df_snippets
    current_site.stocks.snippets.pluck(:name, :label).sort_by(&:first)
  end
end
