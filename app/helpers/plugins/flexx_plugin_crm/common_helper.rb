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

  def rich_text_stocks
    current_site.stocks.rich_texts.order(:name)
  end

  def senders_list
    be = current_site.custom_field_values.find_by_custom_field_slug 'business_email'
    current_site.users.order(:first_name, :last_name) << CamaleonCms::User.new(email: be.value, first_name: current_site.name)
  end
end
