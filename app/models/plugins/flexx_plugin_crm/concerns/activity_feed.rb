module Plugins::FlexxPluginCrm::Concerns::ActivityFeed
  extend ActiveSupport::Concern

  included do
    after_create :create_activity_record
  end

  private

  # Must be implemented by the class that include this concern
  def activity_record_params
    raise 'activity_record_params not implemented.'
  end

  # Must be implemented by the class that include this concern
  def has_activity_record?
    raise 'has_activity_record? not implemented.'
  end

  def create_activity_record
    self.create_task(
      site: site,
      contact: contact,
      aasm_state: :done,
      created_by: created_by,
      updated_by: created_by,
      task_type: activity_record_params[:task_type],
      title: activity_record_params[:title],
      details: activity_record_params[:details]
    ) if has_activity_record?
  end
end
