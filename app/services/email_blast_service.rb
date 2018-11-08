require 'timezone'

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

  def call(task = false, timezone = 'UTC')
    tz = Timezone[timezone].abbr Time.now
    send_at = @scheduled_at.present? ?
      Time.strptime("#{@scheduled_at} #{tz}", '%m/%d/%Y %H:%M %p %Z') :
      Time.current

    message = @site.emails.create(
      recipients_list: @recipients_list,
      recipients_label: @recipients_label,
      subject: @subject,
      body: DynamicFieldsParserService.parse(site: @site, template: @body),
      from: @sender,
      aasm_state: (task ? :task_scheduled : :scheduled),
      send_at: send_at,
      recipients_count: @contact_email_list.count,
      created_by: @user.id
    )

    @contact_email_list.each do |contact|
      message.email_recipients.create(contact_id: contact[0], to: contact[1])
    end
    return if @scheduled_at.present?

    if task
      message.send_task_message!
    else
      message.send_message!
    end
  end
end
