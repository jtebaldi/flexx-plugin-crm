require 'sidekiq'

class ActivityFeedWorker
  include Sidekiq::Worker

  def perform(args)
    params = JSON.parse(args, symbolize_names: true)

    StreamAdapter.client.feed(
      params[:feed_name],
      params[:feed_id]
    ).add_activity(
      actor: params[:actor],
      verb: params[:verb],
      object: params[:object]
    )
  end
end
