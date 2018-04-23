class Plugins::FlexxPluginCrm::Note < ActiveRecord::Base
  self.table_name = 'notes'

  belongs_to :parent, polymorphic: true

  def created_by_user
    CamaleonCms::User.find(created_by)
  end
end
