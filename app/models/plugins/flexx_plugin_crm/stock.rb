class Plugins::FlexxPluginCrm::Stock < ActiveRecord::Base
  self.table_name = 'stocks'

  belongs_to :site, class_name: 'CamaleonCms::Site'
end
