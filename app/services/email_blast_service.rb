require 'timezone'

class EmailBlastService
  def initialize(site:, user:, scheduled_at:, sender:, recipients_list:, subject:, body:, email_id: nil)
    @email_id = email_id
    @site = site
    @user = user
    @scheduled_at = scheduled_at
    @sender = sender
    @recipients_list = recipients_list
    @subject = subject
    @body = body
    @recipients_label = EngageToolsService.recipients_to_labels(recipients_list: recipients_list)
    @contact_email_list = EngageToolsService.recipients_to_contact_email_list(recipients_list: recipients_list, site: site)
  end

  def call(task = nil)
    send_at = @scheduled_at.present? ?
      Time.strptime("#{@scheduled_at} #{Time.current.zone}", '%m/%d/%Y %H:%M %p %Z').in_time_zone :
      Time.current

    message = @site.emails.find_or_initialize_by(id: @email_id)
    message.recipients_list = @recipients_list
    message.recipients_label = @recipients_label
    message.subject = @subject
    message.body = DynamicFieldsParserService.parse(site: @site, template: @body)
    message.from = @sender
    message.aasm_state = (task ? :task_scheduled : :scheduled)
    message.send_at = send_at
    message.recipients_count = @contact_email_list.count
    message.created_by = @user.id
    message.save

    message.email_recipients.where.not(contact_id: @contact_email_list.map(&:first)).destroy_all
    @contact_email_list.each do |contact|
      message.email_recipients.find_or_create_by(contact_id: contact[0]) do |c|
        c.to = contact[1]
        c.task = task
      end
    end
    return if @scheduled_at.present?

    if task
      message.send_task_message!
    else
      message.send_message!
    end
  end
end
