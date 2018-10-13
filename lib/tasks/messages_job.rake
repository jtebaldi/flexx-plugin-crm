namespace :messages_job do
  desc 'Execute messages send job'
  task run: :environment do
    MessagesJobService.queue_new_messages
  end
end
