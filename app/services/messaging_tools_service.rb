class MessagingToolsService
  def self.tags_and_contacts_to_emails(recipients_list:)
    result = Array.new

    return result if recipients_list.nil?

    recipients = recipients_list.gsub('___', ' ').split(',')

    recipients.uniq.each{ |r| result.concat(find_email(recipient: r)) }

    result.uniq
  end

  def self.recipients_to_labels(recipients_list:)
    result = Hash.new { |h, k| h[k] = Array.new }

    return result if recipients_list.nil?

    recipients = recipients_list.gsub('___', ' ').split(',')

    groups = ['Leads', 'Prospects', 'Customers']
    contacts = 0

    recipients.uniq.each do |r|
      if r =~ URI::MailTo::EMAIL_REGEXP
        contacts += 1
      elsif r.to_i > 0
        contacts += 1
      elsif groups.include? r
        result[:groups].push(r)
      else
        result[:tags].push(r)
      end
    end

    result[:contacts] = "#{result.any? ? '+' : ''}#{contacts} #{'contact'.pluralize(contacts)}" if contacts > 0

    result
  end

  private_class_method def self.find_email(recipient:)
    return [recipient] if recipient =~ URI::MailTo::EMAIL_REGEXP

    if recipient.to_i > 0
      contact = Plugins::FlexxPluginCrm::Contact.find_by(id: recipient)

      Array.new.tap { |a| a << contact.email if contact.present? }
    else
      Plugins::FlexxPluginCrm::Contact.tagged_with(recipient).pluck(:email)
    end
  end
end
