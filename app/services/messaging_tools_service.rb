class MessagingToolsService
  MESSAGE_GROUPS = {'All Contacts' => :all,
                    'Leads' => :lead,
                    'Prospects' => :prospect,
                    'Customers' => :customer}

  def self.tags_and_contacts_to_emails(recipients_list:, site:)
    result = Array.new

    return result if recipients_list.nil?

    recipients = recipients_list.gsub('___', ' ').split(',')

    recipients.uniq.each{ |r| result.concat(find_email(recipient: r, site: site)) }

    result.uniq
  end

  def self.recipients_to_labels(recipients_list:)
    result = Hash.new { |h, k| h[k] = Array.new }

    return result if recipients_list.nil?

    recipients = recipients_list.gsub('___', ' ').split(',')

    contacts = 0

    recipients.uniq.each do |r|
      if r =~ URI::MailTo::EMAIL_REGEXP
        contacts += 1
      elsif r.to_i > 0
        contacts += 1
      elsif MESSAGE_GROUPS.has_key? r
        result[:groups].push(r)
      else
        result[:tags].push(r)
      end
    end

    result[:contacts] = "#{result.any? ? '+' : ''}#{contacts} #{'contact'.pluralize(contacts)}" if contacts > 0

    result
  end

  private_class_method def self.find_email(recipient:, site:)
    return [recipient] if recipient =~ URI::MailTo::EMAIL_REGEXP

    if recipient.to_i > 0
      contact = Plugins::FlexxPluginCrm::Contact.find_by(id: recipient)

      Array.new.tap { |a| a << contact.email if contact.present? }
    elsif MESSAGE_GROUPS.has_key? recipient
      site.contacts.send(MESSAGE_GROUPS[recipient]).pluck(:email)
    else
      site.contacts.tagged_with(recipient).pluck(:email)
    end
  end
end
