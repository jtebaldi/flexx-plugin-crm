require 'sidekiq'

class SendMessageWorker
  include Sidekiq::Worker

  def perform(msg_id)
    msg = Plugins::FlexxPluginCrm::Message.find msg_id
    MessagesJobService.send_sms msg
  end
end
