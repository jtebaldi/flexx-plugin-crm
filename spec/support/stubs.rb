require 'rspec/active_model/mocks'

RSpec.configure do |config|
  config.before do |example|
    if example.metadata[:stub_message_model]
      Message = double 'Message'
      messages = []
      messages << mock_model('Msg', id: 1, status: 0, email: 'test1@mail.com')
      messages << mock_model('Msg', id: 2, status: 0, email: 'test2@mail.com')
      expect(Message).to receive(:to_send).and_return messages
    end
  end
end
