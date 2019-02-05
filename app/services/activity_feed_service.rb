class ActivityFeedService
  private_class_method :new

  def self.list_activities(feed_name:, feed_id:, limit: 50)
    new(feed_name, feed_id).list_activities(limit)
  end

  def initialize(feed_name, feed_id)
    @feed_name = feed_name
    @feed_id = feed_id
  end

  def list_activities(limit)
    result = Array.new
    activities = feed.get(limit: limit)['results']

    activities.each do |activity|
      result << OpenStruct.new.tap do |os|
        os.id = activity['id']
        os.actor = parse_actor(activity['actor'])
        os.object = parse_object(activity['object'])
        os.time = Time.find_zone('UTC').parse(activity['time'])
        os.message = activity['message']
        os.labels = activity['labels'].present? ? OpenStruct.new(activity['labels']) : {}
      end
    end

    result
  end

  def feed
    StreamAdapter.client.feed(@feed_name, @feed_id)
  end

  def parse_actor(activity_actor)
    actor_details = activity_actor.split(':')

    case actor_details[0]
    when 'User'
      CamaleonCms::User.find_by(id: actor_details[1])
    when 'Contact'
      Plugins::FlexxPluginCrm::Contact.find_by(id: actor_details[1])
    end
  end

  def parse_object(activity_object)
    object_details = activity_object.split(':')

    case object_details[0]
    when 'Message'
      Plugins::FlexxPluginCrm::Message.find_by(id: object_details[1])
    when 'EmailRecipient'
      Plugins::FlexxPluginCrm::EmailRecipient.find_by(id: object_details[1])
    when 'Task'
      Plugins::FlexxPluginCrm::Task.find_by(id: object_details[1])
    when 'Contact'
      Plugins::FlexxPluginCrm::Contact.find_by(id: object_details[1])
    end
  end
end
