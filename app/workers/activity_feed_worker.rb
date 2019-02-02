require 'sidekiq'

class ActivityFeedWorker
  include Sidekiq::Worker

  def perform(json_params)
    params = JSON.parse(json_params, symbolize_names: true)

    StreamAdapter.client.feed(params[:feed_name], params[:feed_id]).add_activity(params[:args])
  end
end
