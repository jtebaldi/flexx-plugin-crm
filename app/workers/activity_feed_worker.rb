require 'sidekiq'
require 'sidekiq/throttled'

class ActivityFeedWorker
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: :activity_feed

  sidekiq_throttle({
    # https://getstream.io/docs/rate_limit_123/?language=ruby#rate-limits
    :threshold => { limit: ENV.fetch('ACTIVITY_FEED_THRESHOLD', '700').to_i, :period => 1.minute }
  })

  def perform(json_params)
    params = JSON.parse(json_params, symbolize_names: true)

    StreamAdapter.client.feed(params[:feed_name], params[:feed_id]).add_activity(params[:args])
  end
end
