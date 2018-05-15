require "sendgrid-ruby"

class SendgridService
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

  def send_email(to:, body:, send_at:)
    params = {
      personalizations: [{
        to: [{
          email: to
        }]
      }],
      from: {
        email: 'contact@flexx.co'
      },
      subject: 'Flexx Automated Campaign',
      content: [
        {
          type: 'text/plain',
          value: body
        }
      ],
      send_at: send_at
    }

    response = sg.client.mail._("send").post(request_body: params)
  end

  private

  def sg
    @sg ||= SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  end
end
