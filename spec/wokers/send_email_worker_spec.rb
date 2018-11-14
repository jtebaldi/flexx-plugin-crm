require 'rails_helper'
require 'rspec-sidekiq'

describe SendEmailWorker do
  describe 'send email blast' do
    before :each do
      @email = create :email, :with_site, :recipients, aasm_state: 'sending'
      create :user, email: @email.from
    end

    it { is_expected.to be_processed_in :default }

    it 'enqueue job' do
      Sidekiq::Testing.fake!
      SendEmailWorker.perform_async @email.id
      expect(SendEmailWorker).to have_enqueued_sidekiq_job @email.id
    end

    it 'perform job' do
      Sidekiq::Testing.inline!
      VCR.use_cassette 'sendgrid_mail' do
        SendEmailWorker.perform_async @email.id
        @email.reload
        expect(@email.aasm_state).to eq 'sent'
      end
    end
  end

  describe 'send email from task' do
    before :each do
      @email = create :email, :with_site, :recipients, aasm_state: 'task_sending'
      create :user, email: @email.from
    end

    it { is_expected.to be_processed_in :default }

    it 'enqueue job' do
      Sidekiq::Testing.fake!
      SendEmailWorker.perform_async @email.id
      expect(SendEmailWorker).to have_enqueued_sidekiq_job @email.id
    end

    it 'perform job' do
      Sidekiq::Testing.inline!
      VCR.use_cassette 'sendgrid_mail' do
        SendEmailWorker.perform_async @email.id
        @email.reload
        expect(@email.aasm_state).to eq 'task_sent'
      end
    end
  end
end
