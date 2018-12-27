require 'dragonfly'
require 'dragonfly/s3_data_store'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret "65dbd6043b36d3023328bfa27bbd05b8a588c7f8dd565cb3f18ee8dd36e10cd3"

  url_format "/media/:job/:name"

  # datastore :file,
  #   root_path: Rails.root.join('public/system/dragonfly', Rails.env),
  #   server_root: Rails.root.join('public')

  datastore :s3,
    bucket_name: ENV['SIRV_BUCKET'],
    access_key_id: ENV['S3_ACCESS_KEY'],
    secret_access_key: ENV['S3_SECRET_KEY'],
    url_host: ENV['SIRV_ENDPOINT']
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
ActiveSupport.on_load(:active_record) do
  extend Dragonfly::Model
  extend Dragonfly::Model::Validations
end
