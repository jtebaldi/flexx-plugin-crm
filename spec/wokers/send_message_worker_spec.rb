require 'rails_helper'

describe SendMessageWorker do
  it 'job to be peocessed' do
    expect(SendMessageWorker).to be_processed_in :default
  end
end
