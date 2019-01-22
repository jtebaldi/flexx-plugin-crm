class EngageToolsService
  CONTACT_GROUPS = { 'All Contacts' => :all,
                     'Leads' => :lead,
                     'Prospects' => :prospect,
                     'Customers' => :customer }

  def self.email_recipients_to_contacts_list(recipients_list:, site:)
    result = Array.new

    return result if recipients_list.blank?

    recipients = recipients_list.gsub('___', ' ').split(',')

    recipients.uniq.each{ |r| result.concat(find_email(recipient: r, site: site)) }

    result.uniq
  end

  def self.email_recipients_to_labels(recipients_list:)
    result = Hash.new { |h, k| h[k] = Array.new }

    return result if recipients_list.blank?

    recipients = recipients_list.gsub('___', ' ').split(',')

    contacts = 0

    recipients.uniq.each do |r|
      if r =~ URI::MailTo::EMAIL_REGEXP
        contacts += 1
      elsif r.to_i > 0
        contacts += 1
      elsif CONTACT_GROUPS.has_key? r
        result[:groups].push(r)
      else
        result[:tags].push(r)
      end
    end

    result[:contacts] = "#{result.any? ? '+' : ''}#{contacts} #{'contact'.pluralize(contacts)}" if contacts > 0

    result
  end

  def self.message_recipients_to_contacts_list(recipients_list:, site:)
    result = Array.new

    return result if recipients_list.blank?

    recipients_list.gsub('___', ' ').split(',').uniq.each do |r|
      mobile = find_mobile(recipient: r, site: site)

      result.concat(mobile) if mobile.present?
    end

    result.uniq
  end

  def self.message_recipients_to_labels(recipients_list:)
    result = Hash.new { |h, k| h[k] = Array.new }

    return result if recipients_list.blank?

    recipients = recipients_list.gsub('___', ' ').split(',')

    contacts = 0

    recipients.uniq.each do |r|
      if r.to_i > 0
        contacts += 1
      elsif CONTACT_GROUPS.has_key? r
        result[:groups].push(r)
      else
        result[:tags].push(r)
      end
    end

    result[:contacts] = "#{result.any? ? '+' : ''}#{contacts} #{'contact'.pluralize(contacts)}" if contacts > 0

    result
  end

  def self.mark_contact_messages_read(contact:)
    contact.messages.where(read: false).update_all(read: true)
  end

  def self.add_country_code(site:, number:)
    number[0] == "+" ? number : "#{site.get_meta("flexx_crm_settings")[:country_code]}#{number}"
  end

  def self.senders_list(site:)
    be = site.custom_field_values.find_by_custom_field_slug('business_email')

    result = site.users.map do |user|
      {
        name: user.print_name,
        email: user.email
      }
    end
    result << { name: site.name, email: be.value } if be.present?

    result.sort_by { |s| s[:name] }
  end

  private_class_method def self.find_email(recipient:, site:)
    return [[nil, recipient]] if recipient =~ URI::MailTo::EMAIL_REGEXP

    if recipient.to_i > 0
      contact = Plugins::FlexxPluginCrm::Contact.find_by(id: recipient)

      [[contact.id, contact.email]] if contact.present?
    elsif CONTACT_GROUPS.has_key?(recipient)
      site.contacts.send(CONTACT_GROUPS[recipient]).pluck(:id, :email)
    else
      site.contacts.tagged_with(recipient).pluck(:id, :email)
    end
  end

  private_class_method def self.find_mobile(recipient:, site:)
    if recipient.to_i > 0
      mobile = site.phonenumbers.mobile.find_by(contact_id: recipient)

      return [[mobile.contact, mobile.number]] if mobile.present?
    elsif CONTACT_GROUPS.has_key?(recipient)
      site.phonenumbers.mobile.
        select('DISTINCT ON (contact_id) contact_id, number').
        joins(:contact).
        where(contacts: { sales_stage: CONTACT_GROUPS[recipient] }).
        map { |r| [r.contact, r.number] }
    else
      site.phonenumbers.mobile.
        select('DISTINCT ON (contact_id) contact_id, number').
        joins(:contact).
        where(contact_id: site.contacts.tagged_with(recipient).pluck(:id)).
        map { |r| [r.contact, r.number] }
    end
  end
end
