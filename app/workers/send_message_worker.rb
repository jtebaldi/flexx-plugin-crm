require 'sidekiq'

class SendMessageWorker
  include Sidekiq::Worker

  def perform(*args)
    # Do something
  end
end
