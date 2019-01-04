require 'sidekiq'

class SendMessageWorker
  include Sidekiq::Worker

  def perform(message_id)
    message = Plugins::FlexxPluginCrm::Message.find(message_id)
    MessagesJobService.send_message message
  end
end
