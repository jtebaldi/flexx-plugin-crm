class ActivityFeedService
  include Rails.application.routes.url_helpers

  private_class_method :new

  def self.list_activities(feed_name:, feed_id:, limit: 50)
    new(feed_name, feed_id).list_activities(limit)
  end

  def self.list_aggregated_activities(feed_name:, feed_id:, limit: 6)
    new(feed_name, feed_id).list_aggregated_activities(limit)
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
        os.url = activity['url']
      end
    end

    result
  end

  def list_aggregated_activities(limit)
    result = feed.get(limit: limit)['results']

    result.
      map { |a| parse_aggregated_activity(a) }.
      sort { |x, y| y.time <=> x.time }
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
    when 'Stock'
      Plugins::FlexxPluginCrm::Stock.find_by(id: object_details[1])
    end
  end

  def parse_aggregated_activity(activities)
    result = OpenStruct.new

    group_split = activities['group'].split('/')

    case group_split.first
    when 'message_received'
      if activities['activity_count'] == 1
        prefix = 'A message'
        suffix = 'was'
      else
        prefix = "#{activities['activity_count']} messages"
        suffix = 'were'
      end
      contact = parse_actor(group_split[1])

      result.message = "#{prefix} #{suffix} received from #{contact.present? ? contact.print_name : 'unknow'}."
      result.url = contact.present? ? admin_contact_path(contact.id) : '#'
    when 'message_sent'
      if activities['activity_count'] == 1
        prefix = 'A SMS Blast was'
      else
        prefix = "#{activities['activity_count']} SMS Blasts were"
      end

      result.message = "#{prefix} sent."
      result.url = sms_admin_messages_path()
    when 'form_completed'
      contact = parse_actor(group_split[1])

      if activities['activity_count'] == 1
        prefix = 'A Form was'
      else
        prefix = "#{activities['activity_count']} Forms were"
      end

      suffix = contact.present? ? "completed by #{contact.print_name}." : 'completed.'

      result.message = "#{prefix} #{suffix}"
      result.url = contact.present? ? admin_contact_path(contact.id) : ''
    when 'contact_created'
      if activities['activity_count'] == 1
        prefix = 'A Contact was'
      else
        prefix = "#{activities['activity_count']} Contacts were"
      end
      result.message = "#{prefix} created."
    end

    result.id = activities['id']
    result.time = Time.find_zone('UTC').parse(activities['updated_at'])
    result.is_seen = activities['is_seen']

    result
  end
end
