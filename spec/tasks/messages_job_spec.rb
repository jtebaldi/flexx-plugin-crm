require 'rails_helper'
require 'rake'

describe 'rake messages_job:run', type: :task do
  before :all do
    Rake.application.rake_require 'tasks/messages_job' 
  end

  let(:task) { Rake::Task['messages_job:run'] }

  it 'runs gracefully with no message', stub_message_model: true do
    expect { task.execute }.not_to raise_error
  end
end
