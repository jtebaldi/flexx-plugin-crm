class MessagesJobService
  def self.send_new_messages
    Message.to_send.each do |msg|
    end
  end
end
