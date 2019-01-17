class MessageService
  private_class_method :new

  def self.create!(site:, sender:, params:)
    new(site, sender, params).create!
  end

  def initialize(site, sender, params)
    @site = site
    @sender = sender
    @params = params
  end

  def create!
    @site.messages.create!(
      contact_id: contact.id,
      from_number: from_number,
      to_number: to_number,
      message: message,
      send_at: Time.current,
      created_by: @sender.id
    )
  end

  def from_number
    @site.get_option('twilio_campaigns_number')
  end

  def to_number
    mobile = contact.phonenumbers.mobile.first

    EngageToolsService.add_country_code(site: @site, number: mobile.number)
  end

  def contact
    @contact ||= @site.contacts.find_by(id: @params[:contact_id])
  end

  def message
    DynamicFieldsParserService.parse_contact(site: @site, template: @params[:body], contact: contact)
  end
end
