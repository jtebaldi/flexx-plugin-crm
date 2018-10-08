require 'rails_helper'
require 'rake'
require 'rspec-sidekiq'

describe 'rake messages_job:run', type: :task do
  let(:task) { Rake::Task['messages_job:run'] }

  before :all do
    Rake.application.rake_require 'tasks/messages_job' 
  end

  before :each do
    @message = create :message_to_send
  end

  it 'runs gracefully with no message' do
    Sidekiq::Testing.fake!
    expect { task.execute }.not_to raise_error
    expect(SendMessageWorker).to have_enqueued_sidekiq_job @message.id
  end
end
