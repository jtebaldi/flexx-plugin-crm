require 'rails_helper'
require 'rspec-sidekiq'

describe SendMessageWorker do
  describe 'send sms blast' do
    before :each do
      @message = create :message, aasm_state: 'sending', from_number: '15162625087', to_number: '38333334444', message: 'test'
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
        expect(@message.aasm_state).to eq 'sent'
        expect(@message.sid).not_to be_nil
      end
    end
  end

  describe 'send sms form task' do
    before :each do
      @message = create :message, aasm_state: 'task_sending', from_number: '15162625087', to_number: '38333334444', message: 'test'
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
        expect(@message.aasm_state).to eq 'task_sent'
        expect(@message.sid).not_to be_nil
      end
    end
  end
end
