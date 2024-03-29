module Plugins::FlexxPluginCrm::CommonHelper
  def task_type_icon(task_type:)
    case task_type
    when 'phone_call'
      'phone'
    when 'email'
      'envelope'
    when 'message'
      'sms'
    when 'meeting'
      'calendar'
    else
      'list'
    end
  end

  def activity_feed_icon(activity_object)
    case activity_object
    when Plugins::FlexxPluginCrm::Message
      'sms'
    when Plugins::FlexxPluginCrm::EmailRecipient, Plugins::FlexxPluginCrm::Stock
      'envelope'
    when Plugins::FlexxPluginCrm::Task
      task_type_icon(task_type: activity_object.task_type)
    when Plugins::FlexxPluginCrm::Contact
      'retweet'
    else
      'list'
    end
  end

  def invalid_feedback(errors)
    errors.map do |err|
      content_tag :div, class: 'invalid-feedback' do
        err
      end
    end.join('').html_safe
  end

  def invalid_class(errors)
    errors.any? ? ' is-invalid' : ''
  end

  def rich_text_stocks
    current_site.stocks.rich_texts.order(:name)
  end

  def task_stocks
    current_site.stocks.tasks.order(:name)
  end
end
