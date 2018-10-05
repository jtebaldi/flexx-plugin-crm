require 'sidekiq'

class SendMessageWorker
  include Sidekiq::Worker

  def perform(id)
    msg = Plugins::FlexxPluginCrm::Message.find id
    MessagesJobService.send_sms msg
  end
end
