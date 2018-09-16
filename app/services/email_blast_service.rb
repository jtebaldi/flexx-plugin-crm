class EmailBlastService
  def initialize(site:, user:, scheduled:, scheduled_at:, recipients_list:, subject:, body:)
    @recipients_list = recipients_list
    @email_list = MessagingToolsService.tags_and_contacts_to_emails(recipients_list: recipients_list)
    @site = site
    @user = user
    @scheduled = scheduled
    @scheduled_at = scheduled_at
    @subject = subject
    @body = body
  end

  def call
    emails = Array.new

    if @scheduled
      send_at = Time.strptime(@scheduled_at, '%m/%d/%Y %H:%M %p')
    else
      emails = if @email_list.is_a?(Array)
        @email_list.map { |r| { email: r } }
      else
        [ { email: @email_list } ]
      end

      sg_message_id = SendgridAdapter.new.send_email(
        from: {
          email: 'contact@flexx.co',
          name: 'Flexx'
        },
        to: emails,
        subject: @subject,
        body: @body)
    end

    message = @site.emails.create(
      sg_message_id: sg_message_id,
      recipients_list: @recipients_list,
      subject: @subject,
      body: @body,
      from: 'contact@flexx.co',
      status: @scheduled ? 'scheduled' : 'sent',
      send_at: @scheduled ? send_at : Time.now,
      recipients_count: emails.count,
      created_by: @user.id
    )

    emails.each do |r|
      message.email_recipients.create(to: r[:email])
    end
  end
end
