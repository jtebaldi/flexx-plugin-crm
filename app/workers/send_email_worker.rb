require 'sidekiq'

class SendEmailWorker
  include Sidekiq::Worker

  def perform(recipient_id)
    recipient = Plugins::FlexxPluginCrm::EmailRecipient.find(recipient_id)
    MessagesJobService.send_email recipient
  end
end
