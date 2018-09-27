require 'rails_helper'

describe MessagesJobService, stub_message_model: { find: 2 } do
  it 'send sms message' do
    VCR.use_cassette 'twilo_sms' do
      MessagesJobService.send_message Message.find 2
      expect(Message.find(2).status).to eq :sent
    end
  end
end
