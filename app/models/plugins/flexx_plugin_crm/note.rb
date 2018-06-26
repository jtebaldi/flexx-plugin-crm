class Plugins::FlexxPluginCrm::Note < ActiveRecord::Base
  include Plugins::FlexxPluginCrm::Concerns::HasUsers

  self.table_name = 'notes'

  belongs_to :parent, polymorphic: true

  def created_by_user
    user_class.find(created_by)
  end
end
