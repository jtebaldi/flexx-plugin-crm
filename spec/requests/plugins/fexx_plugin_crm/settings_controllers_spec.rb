require 'rails_helper'

RSpec.describe 'Plugins::FexxPluginCrm::SettingsController', type: :request do
  describe 'GET /admin/next/settings' do
    it 'open settings page' do
      sign_in
      get admin_settings_path
      expect(response).to have_http_status(200)
    end
  end
end
