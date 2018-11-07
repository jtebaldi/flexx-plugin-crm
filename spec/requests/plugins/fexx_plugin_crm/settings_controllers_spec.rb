require 'rails_helper'

RSpec.describe "Plugins::FexxPluginCrm::SettingsControllers", type: :request do

  describe "GET /admin/next/settings" do
    it "works!" do
      # sign_in create :user
      get admin_settings_path
      expect(response).to have_http_status(200)
    end
  end
end
