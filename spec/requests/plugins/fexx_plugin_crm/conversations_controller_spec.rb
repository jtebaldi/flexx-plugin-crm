require 'rails_helper'

RSpec.describe 'Plugins::FexxPluginCrm::ConversationsController', type: :request do
  describe 'GET /admin/next/conversations' do
    it 'render index action' do
      user = sign_in
      contact = create :contact, site_id: user.parent_id
      create :message, :done, :received, contact: contact, site: contact.site, created_by: user.id
      get admin_conversations_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /admin/next/conversations/:contact_id' do
    it 'render conversations thread' do
      user = sign_in
      contact = create :contact, site_id: user.parent_id
      create :message, :done, :received, contact: contact, site: contact.site, created_by: user.id
      xhr :get, admin_conversation_path(contact)
      expect(response).to have_http_status(200)
    end
  end
end
