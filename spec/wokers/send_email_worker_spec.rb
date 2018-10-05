require 'rails_helper'
require 'rspec-sidekiq'

describe SendEmailWorker do
  it { is_expected.to be_processed_in :default }

  it 'enqueue job' do
    Sidekiq::Testing.fake!
    SendEmailWorker.perform_async 1
    expect(SendEmailWorker).to have_enqueued_sidekiq_job 1
  end

  it 'perform job' do
    email = create :email
    Sidekiq::Testing.inline!
    VCR.use_cassette 'sendgrid_mail' do
      SendEmailWorker.perform_async email.email_recipients.first.id
      email.reload
      expect(email.email_recipients.first.status).to eq 'sent'
    end
  end
end
