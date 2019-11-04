class AutomatedCampaignService
  def self.apply_form_campaigns(form:, contact:)
    form.automated_campaigns.active.each do |campaign|
      apply_campaign(contact: contact, campaign: campaign) unless contact.subscribed_campaigns.include?(campaign)
    end
  end

  def self.apply_campaign(contact:, campaign:)
    subscription = campaign.subscriptions.create(contact_id: contact.id)

    campaign.ordered_steps.each do |step|
      subscription.steps.create(
        automated_campaign_step_id: step.id,
        send_at: Time.now + step.due_on_value.send(step.due_on_unit)
      )
    end
  end

  def self.update_next_step(subscription:)
    if subscription.ordered_scheduled_steps.count > 0
      next_step = subscription.ordered_scheduled_steps.first
      subscription.update(next_step: next_step, next_send_at: next_step.send_at)
    else
      subscription.update(aasm_state: :finished)
    end
  end
end
