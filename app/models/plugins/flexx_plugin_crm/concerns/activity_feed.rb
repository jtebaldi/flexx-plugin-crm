module Plugins::FlexxPluginCrm::Concerns::ActivityFeed
  extend ActiveSupport::Concern

  included do
    before_create :create_activity_record
  end

  private

  # Must be implemented by the class that include this concern
  def activity_record_params
  end

  # Must be implemented by the class that include this concern
  def has_activity_record?
    false
  end

  def create_activity_record
    self.create_task(
      site: self.site,
      contact: self.contact,
      aasm_state: :done,
      created_by: self.created_by,
      task_type: self.activity_record_params[:task_type],
      title: self.activity_record_params[:title],
      details: self.activity_record_params[:details]
    ) if self.has_activity_record?
  end
end
