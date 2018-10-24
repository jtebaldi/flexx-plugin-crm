class EmailBlastService
  def initialize(site:, user:, scheduled_at:, sender:, recipients_list:, subject:, body:)
    @site = site
    @user = user
    @scheduled_at = scheduled_at
    @sender = sender
    @recipients_list = recipients_list
    @subject = subject
    @body = body
    @recipients_label = MessagingToolsService.recipients_to_labels(recipients_list: recipients_list)
    @contact_email_list = MessagingToolsService.recipients_to_contact_email_list(recipients_list: recipients_list, site: site)
  end

  def call
    send_at = @scheduled_at.present? ? Time.strptime(@scheduled_at, '%m/%d/%Y %H:%M %p') : Time.now

    message = @site.emails.create(
      recipients_list: @recipients_list,
      recipients_label: @recipients_label,
      subject: @subject,
      body: DynamicFieldsParserService.parse(site: @site, template: @body),
      from: @sender,
      aasm_state: :scheduled,
      send_at: send_at,
      recipients_count: @contact_email_list.count,
      created_by: @user.id
    )

    @contact_email_list.each do |contact|
      message.email_recipients.create(contact_id: contact[0], to: contact[1])
    end

    message.send_message! unless @scheduled_at.present?
  end
end
