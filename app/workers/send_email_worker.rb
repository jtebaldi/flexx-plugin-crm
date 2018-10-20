require 'sidekiq'

class SendEmailWorker
  include Sidekiq::Worker

  def perform(email_id)
    email = Plugins::FlexxPluginCrm::Email.find(email_id)
    MessagesJobService.send_email email
  end
end
