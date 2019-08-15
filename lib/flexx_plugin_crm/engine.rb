require 'groupdate'

if Rails.env.test?
  require 'figaro'
  require 'camaleon_cms'
end

module FlexxPluginCrm
  ASSET_PATH = File.expand_path("../../..", __FILE__)

  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.assets.paths += [FlexxPluginCrm::ASSET_PATH]
  end
end
