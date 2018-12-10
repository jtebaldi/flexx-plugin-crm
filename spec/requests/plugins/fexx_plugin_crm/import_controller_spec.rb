require 'rails_helper'

RSpec.describe 'Plugins::FlexxPluginCrm::ImportController', type: :request do
  describe 'GET /admin/next/import' do
    it 'render import form' do
      sign_in
      get admin_import_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'PATCH /admin/next/import/contacts' do
    it 'create contacts' do
      sign_in
      file = Rack::Test::UploadedFile.new 'spec/examples/contacts.csv', 'text/csv'
      expect do
        expect do
          post admin_import_contacts_path, contacts: file
        end.to change { Plugins::FlexxPluginCrm::Phonenumber.count }.by 2
      end.to change { Plugins::FlexxPluginCrm::Contact.count }.by 2
      expect(response).to redirect_to action: :index
      contact = Plugins::FlexxPluginCrm::Contact.find_by_email 'jconor@email.com'
      expect(contact.phonenumbers.first.number).to eq '+12015550123'
      contact = Plugins::FlexxPluginCrm::Contact.find_by_email 'mbrown@email.com'
      expect(contact.phonenumbers.first.number).to eq '+12015550124'
    end
  end
end
