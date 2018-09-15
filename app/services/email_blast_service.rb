class EmailBlastService
  def initialize(site:, recipients_list:, subject:, body:)
    @recipients_list = recipients_list
    @recipients = MessagingToolsService.tags_and_contacts_to_emails(recipients: recipients_list)
    @site = site
    @subject = subject
    @body = body
  end

  def call
    emails = if @recipients.is_a?(Array)
      @recipients.map { |r| { email: r } }
    else
      [ { email: @recipients } ]
    end

    sg_message_id = SendgridAdapter.new.send_email(
      from: {
        email: 'contact@flexx.co',
        name: 'Flexx'
      },
      to: emails,
      subject: @subject,
      body: @body)

    message = @site.emails.create(
      sg_message_id: sg_message_id,
      recipients_list: @recipients_list,
      subject: @subject,
      body: @body,
      status: 'sent',
      send_at: Time.now,
      recipients_count: emails.count,
      created_by: @user
    )

    emails.each do |r|
      message.email_recipients.create(to: r[:email])
    end
  end
end
