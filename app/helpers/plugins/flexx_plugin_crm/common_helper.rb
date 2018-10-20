module Plugins::FlexxPluginCrm::CommonHelper
  def task_type_icon(task_type:)
    case task_type
    when 'phone_call'
      'phone'
    when 'email'
      'envelope'
    when 'message'
      'comment'
    when 'meeting'
      'calendar'
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
end
