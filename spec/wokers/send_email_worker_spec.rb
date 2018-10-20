require 'rails_helper'
require 'rspec-sidekiq'

describe SendEmailWorker do
  before :each do
    @email = create :email, aasm_state: 'sending'
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
