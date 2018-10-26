require 'twilio-ruby'

class TwilioAdapter
  def send_sms(message:)
    sid = message.site.get_option('twilio_account_sid')
    token = message.site.get_option('twilio_auth_token')

    client(sid, token).api.account.messages.create(
      from: message.from_number,
      to: message.to_number,
      body: message.message,
      status_callback: status_callback_url(message.site)
    )
  end

  def call_confirmation_flow(to:, parameters:)
    flow = client.studio.flows(ENV["TWILIO_CONFIRMATION_FLOW_SID"]).engagements.create(
      from: ENV["TWILIO_CONFIRMATION_FLOW_NUMBER"],
      to: to,
      parameters: parameters.to_json
    )
  end

  private

  def client(sid, token)
    @client ||= Twilio::REST::Client.new(sid, token)
  end

  def status_callback_url(site)
    Rails.application.routes.url_helpers.twilio_status_admin_webhooks_url(host: site.get_domain)
  end
end
