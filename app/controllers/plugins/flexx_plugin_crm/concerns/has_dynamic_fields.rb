module Plugins::FlexxPluginCrm::Concerns::HasDynamicFields
  extend ActiveSupport::Concern

  def df_defaults
    [
      ['E-mail', 'email'],
      ['First Name', 'first_name'],
      ['Last Name', 'last_name']
    ]
  end

  def df_snippets
    current_site.stocks.snippets.pluck(:name, :label).sort_by(&:first)
  end
end
