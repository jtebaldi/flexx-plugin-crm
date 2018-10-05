require 'rails_helper'
require 'rspec-sidekiq'

describe SendMessageWorker do
  before :each do
    @message = create :message
  end

  it { is_expected.to be_processed_in :default }

  it 'enqueue job' do
    Sidekiq::Testing.fake!
    SendMessageWorker.perform_async @message.id
    expect(SendMessageWorker).to have_enqueued_sidekiq_job @message.id
  end

  it 'perform job' do
    Sidekiq::Testing.inline!
    VCR.use_cassette 'twilio_sms' do
      SendMessageWorker.perform_async @message.id
      @message.reload
      expect(@message.status).to eq 'sent'
      expect(@message.sid).not_to be_nil
    end
  end
end
