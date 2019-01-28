module Plugins::FlexxPluginCrm::Concerns::ActivityFeed
  extend ActiveSupport::Concern

  included do
    after_save :add_activity_record
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

  def add_activity_record
    ActivityFeedWorker.perform_async(activity_record_params.to_json) if has_activity_record?
  end
end
