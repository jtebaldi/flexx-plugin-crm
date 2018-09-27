require 'sidekiq'

class SendMessageWorker
  include Sidekiq::Worker

  def perform(id)
    msg = Message.find id
    MessagesJobService.send_message msg
  end
end
