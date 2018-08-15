class AutomatedCampaignService
  def self.apply_campaigns(contact:)
    contact.cama_contact_form.automated_campaigns.active.each { |campaign| apply_campaign(contact: contact, campaign: campaign) }
  end

  def self.apply_campaign(contact:, campaign:)
    campaign.steps.active.each do |step|
      contact.automated_campaign_jobs.create(
        site_id: contact.site_id,
        automated_campaign_id: campaign.id,
        automated_campaign_step_id: step.id,
        send_to: contact.email,
        send_at: Time.now + step.due_on_value.send(step.due_on_unit),
        message: step.message,
        status_changed_at: Time.now
      )
    end
  end
end
