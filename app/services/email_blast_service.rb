class EmailBlastService
  def initialize(site:, user:, scheduled_at:, recipients_list:, subject:, body:)
    @site = site
    @user = user
    @scheduled_at = scheduled_at
    @recipients_list = recipients_list
    @subject = subject
    @body = body
    @recipients_label = MessagingToolsService.recipients_to_labels(recipients_list: recipients_list)
    @email_list = MessagingToolsService.tags_and_contacts_to_emails(recipients_list: recipients_list, site: site)
  end

  def call
    send_at = @scheduled_at.present? ? Time.strptime(@scheduled_at, '%m/%d/%Y %H:%M %p') : Time.now

    emails = if @email_list.is_a?(Array)
      @email_list.map { |r| { email: r } }
    else
      [ { email: @email_list } ]
    end

    message = @site.emails.create(
      recipients_list: @recipients_list,
      recipients_label: @recipients_label,
      subject: @subject,
      body: DynamicFieldsParserService.parse(site: @site, template: @body),
      from: 'contact@flexx.co',
      aasm_state: :scheduled,
      send_at: send_at,
      recipients_count: emails.count,
      created_by: @user.id
    )

    emails.each do |r|
      message.email_recipients.create(to: r[:email])
    end

    message.send_message! unless @scheduled_at.present?
  end
end
