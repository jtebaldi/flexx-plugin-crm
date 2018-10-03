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
end
