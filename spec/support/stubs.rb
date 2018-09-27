require 'rspec/active_model/mocks'

RSpec.configure do |config|
  config.before do |example|
    if (stub_methods = example.metadata[:stub_message_model])
      Message = double 'Message'
      to_send = []
      sending = []
      sent = []
      to_send << mock_model('Msg', id: 1, status: :to_send, type: :email, update: true)
      to_send << mock_model('Msg', id: 2, status: :to_send, type: :sms, update: true)
      sending << mock_model('Msg', id: 1, status: :sending, type: :email,
        text: 'Message 1', email: 'test1@mail.com', update: true)
      sending << mock_model('Msg', id: 2, status: :sending, type: :sms,
        text: 'Message 2', phone: '+09876543210', update: true)
      sent << mock_model('Msg', id: 1, status: :sent)
      sent << mock_model('Msg', id: 2, status: :sent)
      stub_methods.each do |k, v|
        case k
        when :to_send
          expect(Message).to receive(k).and_return to_send
        else
          i = v - 1
          expect(Message).to receive(k).at_least(:once).with(v).and_return(sending[i], sent[i])
        end
      end
    end
  end
end
