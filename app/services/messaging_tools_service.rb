class MessagingToolsService
  def self.tags_and_contacts_to_emails(recipients:)
    result = Array.new

    if recipients.is_a?(String)
      find_email(recipient: recipients)
    elsif recipients.is_a?(Array)
      recipients.uniq.each{ |r| result.concat(find_email(recipient: r)) }
    end

    result.uniq
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