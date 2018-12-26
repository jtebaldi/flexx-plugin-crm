require 'mustache'

class DynamicFieldsParserService
  def self.parse(site:, template:, escape: true)
    self.new(site, template, nil, escape).parse
  end

  def self.parse_contact(site:, template:, contact:, escape: true)
    self.new(site, template, contact, escape).parse
  end

  def initialize(site, template, contact, escape = true)
    @site = site
    @template = escape ? template : template.gsub('{{', '{{{').gsub('}}', '}}}')
    @contact = contact
  end

  def parse
    fields = Hash[@site.stocks.snippets.pluck(:label, :contents)]
    fields.merge!(load_contact_fields)

    Mustache.render(@template, fields)
  end

  private

  def load_contact_fields
    if @contact.present?
      {
        contact_first_name: @contact.first_name,
        contact_last_name: @contact.last_name,
        contact_email: @contact.email
      }
    else
      {
        contact_first_name: '{{contact_first_name}}',
        contact_last_name: '{{contact_last_name}}',
        contact_email: '{{contact_email}}'
      }
    end
  end
end
