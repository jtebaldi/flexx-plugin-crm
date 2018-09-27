require 'rails_helper'
require 'rspec-sidekiq'

describe SendMessageWorker do
  it { is_expected.to be_processed_in :default }

  it 'enqueue job' do
    SendMessageWorker.perform_async 1
    expect(SendMessageWorker).to have_enqueued_sidekiq_job 1
  end

  it 'perform job', stub_message_model: { find: 1 } do
    Sidekiq::Testing.inline!
    VCR.use_cassette 'sendgrid_mail' do
      SendMessageWorker.perform_async 1
      expect(Message.find(1).status).to eq :sent
    end
  end
end
