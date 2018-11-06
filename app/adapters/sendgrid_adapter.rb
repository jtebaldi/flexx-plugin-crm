require "sendgrid-ruby"

class SendgridAdapter
  def initialize(site:)
    @site = site
  end

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

  # Send email
  # @param from [Hash{Symbol=>String, Symbol=>String}]
  # @option from [String] :email
  # @option from [String] :name
  # @param to [Array<Hash{Symbol=>String, Symbol=>String}>]
  # @option to [String] :email
  # @option to [String] :name
  # @param body [String]
  # @paran send_at [String]
  # @return [String, NillClass] message id
  def send_email(from:, to:, subject:, body:, send_at: nil)
    personalizations = Array.new.tap do |p|
      to.each do |t|
        p << {
          to: [t],
          substitutions: dynamic_fields(t[:email])
        }
      end
    end

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
        },
        click_tracking: { enable: true },
        open_tracking: { enable: true }
      }
    }

    params[:send_at] = send_at if send_at.present?

    response = sg.client.mail._("send").post(request_body: params)

    if (200..299).include?(response.status_code.to_i)
      response.headers["x-message-id"][0]
    else
      raise response.body
    end
  end

  private

  def sg
    @sg ||= SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  end

  def dynamic_fields(email)
    contact_details(email).merge(site_snippets)
  end

  def contact_details(email)
    contact = @site.contacts.find_by(email: email)

    if contact.present?
      {
        "{{first_name}}" => contact.first_name,
        "{{last_name}}" => contact.last_name,
        "{{email}}" => email
      }
    else
      {}
    end
  end

  def site_snippets
    @site_snippets ||= Hash.new.tap do |result|
      @site.stocks.snippets.each do |row|
        result["{#{row.label}}"] = row.contents
      end
    end
  end
end
