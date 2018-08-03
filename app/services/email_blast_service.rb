class EmailBlastService
  def initialize(site:, recipients:, subject:, body:)
    @site = site
    @recipients = if recipients.is_a?(Array)
      recipients.map { |r| { email: r } }
    else
      [ { email: recipients } ]
    end
    @subject = subject
    @body = body
  end

  def call
    sg_message_id = SendgridAdapter.new.send_email(
      from: {
        email: 'contact@flexx.co',
        name: 'Flexx'
      },
      to: @recipients,
      subject: @subject,
      body: @body)

    message = @site.emails.create(
      sg_message_id: sg_message_id,
      subject: @subject,
      body: @body,
      created_by: @user
    )

    @recipients.each do |r|
      message.email_recipients.create(to: r[:email])
    end
  end
end
