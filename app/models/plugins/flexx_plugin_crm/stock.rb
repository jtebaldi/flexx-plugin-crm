class Plugins::FlexxPluginCrm::Stock < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::HasUsers

  self.table_name = 'stocks'

  belongs_to :site, class_name: 'CamaleonCms::Site'

  default_scope { order(:name) }

  scope :snippets, -> { where(stock_type: 'snippet') }
  scope :rich_texts, -> { where(stock_type: 'rich_text') }
  scope :htmls, -> { where(stock_type: 'html') }

  def created_by_user
    self.class.user_class.find(created_by)
  end
end
