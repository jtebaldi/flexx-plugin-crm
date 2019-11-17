class AutomatedCampaignReportsService

  private_class_method :new

  def initialize(campaign)
    @campaign = campaign
  end

  def self.generate(campaign:)
    new(campaign).generate
  end

  def generate
    emails = Plugins::FlexxPluginCrm::Email.all.where(automated_campaign_subscription_id: @campaign.subscriptions.pluck(:id))

    result = {
      subscribed: @campaign.subscriptions.count,
      running: @campaign.subscriptions.running.count,
      ended: @campaign.subscriptions.ended.count,
      unsubscribed: @campaign.subscriptions.unsubscribed.count,
      emails_sent: emails.sent.count,
      emails_opened: emails.sum(:opened_count),
      emails_clicked: emails.sum(:clicked_count),
      emails_bounced: emails.sum(:bounced_count),
      emails_dropped: emails.sum(:dropped_count),
      emails_spam: emails.sum(:spam_count),
      steps: []
    }

    @campaign.steps.each do |step|
      emails = Plugins::FlexxPluginCrm::Email.all.where(automated_campaign_subscription_step_id: step.subscription_steps.pluck(:id))
      step_result = {
        name: step.name,
        contacts: @campaign.subscriptions.not_ended.where(next_step: step.id).count,
        emails_sent: emails.sent.count,
        emails_opened: emails.sum(:opened_count),
        emails_clicked: emails.sum(:clicked_count),
        emails_bounced: emails.sum(:bounced_count),
        emails_dropped: emails.sum(:dropped_count),
        emails_spam: emails.sum(:spam_count)
      }

      result[:steps] << step_result
    end

    result
  end
end
