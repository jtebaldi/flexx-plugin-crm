class Plugins::FlexxPluginCrm::Stock < ActiveRecord::Base
  self.table_name = 'stocks'

  belongs_to :site, class_name: 'CamaleonCms::Site'

  scope :text_snippets, -> { where(stock_type: 'text') }
  scope :rich_text_snippets, -> { where(stock_type: 'rich_text') }
end
