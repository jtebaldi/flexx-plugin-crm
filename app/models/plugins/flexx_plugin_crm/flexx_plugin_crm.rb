class Plugins::FlexxPluginCrm::FlexxPluginCrm < ActiveRecord::Base
  belongs_to :site, class_name: "CamleonCms::Site"

end
