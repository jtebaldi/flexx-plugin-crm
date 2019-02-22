require 'stream'

class StreamAdapter
  def self.client
    @stream_client ||= Stream::Client.new(
      ENV['STREAM_API_KEY'],
      ENV['STREAM_API_SECRET'],
      location: ENV['STREAM_APP_LOCATION']
    )
  end
end
