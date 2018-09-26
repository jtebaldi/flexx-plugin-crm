if Rails.env.test?
  require 'camaleon_cms'
  require 'acts-as-taggable-on'
end

module FlexxPluginCrm
  ASSET_PATH = File.expand_path("../../..", __FILE__)

  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec
    end

    config.assets.paths += [FlexxPluginCrm::ASSET_PATH]
  end
end
