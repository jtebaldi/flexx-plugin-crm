require 'mustache'

class DynamicFieldsParserService
  def self.parse(site:, template:)
    self.new(site, template, nil).parse
  end

  def self.parse_contact(site:, template:, contact:)
    self.new(site, template, contact).parse
  end

  def initialize(site, template, contact)
    @site = site
    @template = template
    @contact = contact
  end

  def parse
    fields = Hash[ @site.stocks.snippets.pluck(:label, :contents) ]
    fields.merge!(load_contact_fields)

    Mustache.render(@template, fields)
  end

  private

  def load_contact_fields
    if @contact.present?
      {
        first_name: @contact.first_name,
        last_name: @contact.last_name,
        email: @contact.email
      }
    else
      {
        first_name: '{{first_name}}',
        last_name: '{{last_name}}',
        email: '{{email}}'
      }
    end
  end
end
