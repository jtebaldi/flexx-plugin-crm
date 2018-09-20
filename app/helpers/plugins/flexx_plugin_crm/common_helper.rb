module Plugins::FlexxPluginCrm::CommonHelper
  def task_type_icon(task_type:)
    case task_type
    when 'phone_call'
      'phone'
    when 'email'
      'envelope'
    when 'message'
      'comment'
    else
      'list'
    end
  end

  def recipients_to_labels(recipients_list)
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
end
