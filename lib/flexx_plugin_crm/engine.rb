module FlexxPluginCrm
  ASSET_PATH = File.expand_path("../../..", __FILE__)

  class Engine < ::Rails::Engine
    config.assets.paths += [FlexxPluginCrm::ASSET_PATH]
  end
end
