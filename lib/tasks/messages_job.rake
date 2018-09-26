namespace :messages_job do
  desc 'Execute messages send job'
  task run: :environment do
    MessagesJobService.send_new_messages
  end
end
