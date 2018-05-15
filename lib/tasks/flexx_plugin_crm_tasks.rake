# desc "Explaining what the task does"
# task :flexx_plugin_crm do
#   # Task goes here
# end

desc "Execute automated campaigns jobs"

task :flexx_plugin_crm_execute_jobs do
  Plugins::FlexxPluginCrm::AutomatedCampaignJob.queue.each do |job|
    SendgridService.new.send_email(
      to: job.contact.email,
      body: job.message,
      send_at: job.send_at.to_i
    )
  end
end
