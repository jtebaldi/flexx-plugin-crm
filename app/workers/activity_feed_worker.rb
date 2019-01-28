require 'sidekiq'
require 'stream'

class ActivityFeedWorker
  include Sidekiq::Worker

  def perform(args)
    params = JSON.parse(args, symbolize_names: true)

    stream_client.feed(
      params[:feed_name],
      params[:feed_id]
    ).add_activity(
      actor: params[:actor],
      verb: params[:verb],
      object: params[:object]
    )
  end

  def stream_client
    @stream_client ||= Stream::Client.new(
      ENV['STREAM_API_KEY'],
      ENV['STREAM_API_SECRET'],
      location: ENV['STREAM_APP_LOCATION']
    )
  end
end
