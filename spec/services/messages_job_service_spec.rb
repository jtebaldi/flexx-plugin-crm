require 'rails_helper'

describe MessagesJobService do
  it 'send sms message' do
    message = create :message, aasm_state: 'sending'
    VCR.use_cassette 'twilio_sms' do
      MessagesJobService.send_sms message
      message.reload
      expect(message.aasm_state).to eq 'sent'
    end
  end
end
