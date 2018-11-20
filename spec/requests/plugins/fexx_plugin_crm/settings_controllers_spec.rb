require 'rails_helper'
# require 'devise'

RSpec.describe "Plugins::FexxPluginCrm::SettingsController", type: :request do
  # include Warden::Test::Helpers
  # include Devise::TestHelpers
  # include ControllerHelpers

  describe "GET /admin/next/settings" do
    it "works!" do
      # Warden.test_mode!
      # sign_in create :user
      # require 'pry-byebug'; binding.pry
      site = create :site
      user = create :user, role: 'admin', parent_id: site.id
      expect_any_instance_of(CamaleonCms::User).to receive(:the_usernome).and_return(user.fullname) 
      # login_as(user, :scope => :user)
      # sign_in user
      expect_any_instance_of(Plugins::FlexxPluginCrm::SettingsController).to receive(:cama_authenticate).and_return(user)
      expect_any_instance_of(CamaleonCms::CamaleonController).to receive(:current_user).and_return(user)
      # allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      # allow(controller).to receive(:current_user).and_return(user)
      get admin_settings_path
      expect(response).to have_http_status(200)
    end
  end
end
