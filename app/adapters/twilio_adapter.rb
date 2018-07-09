class TwilioAdapter
  def send_sms(to:, body:)
    sms = client.api.account.messages.create(
      from: ENV["TWILIO_NUMBER"],
      to: to,
      body: body,
      status_callback: ENV["TWILIO_STATUS_CALLBACK"]
    )
  end

  def call_confirmation_flow(to:, parameters:)
    flow = client.studio.flows(ENV["TWILIO_CONFIRMATION_FLOW_SID"]).engagements.create(
      from: ENV["TWILIO_NUMBER"],
      to: to,
      parameters: parameters.to_json
    )
  end

  private

  def client
    @client ||= Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
  end
end
