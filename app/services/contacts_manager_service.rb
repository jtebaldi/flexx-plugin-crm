require "sendgrid-ruby"

class ContactsManagerService
  def contact_lists
    response = sg.client.contactdb.lists.get()

    if response.status_code == "200"
      JSON.parse(response.body)["lists"]
    else
      []
    end
  end

  def list_details(id:)
    response = sg.client.contactdb.lists._(id).recipients.get()

    if response.status_code == "200"
      JSON.parse(response.body)["recipients"]
    else
      []
    end
  end

  private

  def sg
    @sg ||= SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  end
end
