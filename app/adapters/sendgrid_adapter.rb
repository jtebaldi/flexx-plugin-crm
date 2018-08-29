require "sendgrid-ruby"

class SendgridAdapter
  def create_list(name:)
    response = sg.client.contactdb.lists.post(request_body: { name: name })

    JSON.parse(response.body)['id'] if (200..299).include?(response.status_code.to_i)
  end

  def create_contact(contact_details:)
    response = sg.client.contactdb.recipients.post(request_body: contact_details)

    JSON.parse(response.body)['persisted_recipients'][0] if (200..299).include?(response.status_code.to_i)
  end

  def update_contact(contact_details:)
    response = sg.client.contactdb.recipients.patch(request_body: contact_details)

    JSON.parse(response.body)['persisted_recipients'][0] if (200..299).include?(response.status_code.to_i)
  end

  def create_campaign(subject:, sender:, list:, body:)
    campaign_details = {
      subject: subject,
      sender_id: sender,
      list_ids: list,
      plain_content: body
    }

    response = sg.client.campaigns.post(request_body: campaign_details)

    JSON.parse(response.body)["id"] if (200..299).include?(response.status_code.to_i)
  end

  def send_campaign(campaign_id:)
    response = sg.client.campaigns._(campaign_id).schedules.now.post()

    JSON.parse(response.body)["status"] if (200..299).include?(response.status_code.to_i)
  end

  def schedule_campaign(campaign_id:, send_at:)
    response = sg.client.campaigns._(campaign_id).schedules.post(request_body: { send_at: send_at })

    JSON.parse(response.body)["status"] if (200..299).include?(response.status_code.to_i)
  end

  def send_email(from:, to:, subject:, body:, send_at: nil)
    personalizations = Array.new.tap { |p| to.each { |t| p << { to: [t] } } }
    params = {
      personalizations: personalizations,
      from: from,
      subject: subject,
      content: [
        {
          type: 'text/html',
          value: body
        }
      ],
      tracking_settings: {
        subscription_tracking: {
          enable: true,
          html: "If you'd like to unsubscribe and stop receiving these emails <% click here %>."
        }
      }
    }

    params[:send_at] = send_at if send_at.present?

    response = sg.client.mail._("send").post(request_body: params)

    response.headers["x-message-id"][0] if (200..299).include?(response.status_code.to_i)
  end

  private

  def sg
    @sg ||= SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  end
end