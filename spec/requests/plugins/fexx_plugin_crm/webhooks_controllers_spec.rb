require 'rails_helper'

RSpec.describe "Plugins::FexxPluginCrm::WebhooksControllers", type: :request do
  describe "POST /admin/next/webhooks/sendgrid_events" do
    before :each do
      @email = create :email, :with_site, :recipients, sg_message_id: 'tk_wpzmPSMGGQ3HWqJ6Bkg'
    end

it "open event" do
      post sendgrid_events_admin_webhooks_path, open_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(204)
      @email.reload
      expect(@email.opened_count).to eq 1
      recipient = @email.email_recipients.find_by_to('test1@mail.net')
      expect(recipient.status).to eq 'open'
      expect(recipient.opened_at).not_to be_nil 
    end

    it "click event" do
      post sendgrid_events_admin_webhooks_path, open_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post sendgrid_events_admin_webhooks_path, { _json: [
        {
          "email": "test1@mail.net",
          "timestamp": Time.now.to_i,
          "ip": "77.222.3.247",
          "sg_event_id": "E_1GuLXASuSE-OtaaCmj5w",
          "sg_message_id": "tk_wpzmPSMGGQ3HWqJ6Bkg.filter0109p3las1-17392-5BE02D7C-B.0",
          "useragent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14) AppleWebKit/605.1.15 (KHTML, like Gecko)",
          "event": "click"
        }
      ]}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(204)
      @email.reload
      expect(@email.clicked_count).to eq 1
      recipient = @email.email_recipients.find_by_to('test1@mail.net')
      expect(recipient.status).to eq 'click'
      expect(recipient.clicked_at).not_to be_nil 

      post sendgrid_events_admin_webhooks_path, open_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      @email.reload
      recipient = @email.email_recipients.find_by_to('test1@mail.net')
      expect(recipient.status).to eq 'click'
    end

    it "unsubscribed event" do
      post sendgrid_events_admin_webhooks_path, open_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      post sendgrid_events_admin_webhooks_path, { _json: [
        {
          "email": "test1@mail.net",
          "timestamp": Time.now.to_i,
          "ip": "77.222.3.247",
          "sg_event_id": "E_1GuLXASuSE-OtaaCmj5w",
          "sg_message_id": "tk_wpzmPSMGGQ3HWqJ6Bkg.filter0109p3las1-17392-5BE02D7C-B.0",
          "useragent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14) AppleWebKit/605.1.15 (KHTML, like Gecko)",
          "event": "unsubscribe"
        }
      ]}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(204)
      @email.reload
      expect(@email.unsubscribed_count).to eq 1
      recipient = @email.email_recipients.find_by_to('test1@mail.net')
      expect(recipient.status).to eq 'unsubscribe'
      expect(recipient.unsubscribed_at).not_to be_nil 

      post sendgrid_events_admin_webhooks_path, open_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      @email.reload
      recipient = @email.email_recipients.find_by_to('test1@mail.net')
      expect(recipient.status).to eq 'unsubscribe'
    end

    it "bounce event" do
      post sendgrid_events_admin_webhooks_path, { _json: [
        {
          "email": "test1@mail.net",
          "timestamp": Time.now.to_i,
          "ip": "77.222.3.247",
          "sg_event_id": "E_1GuLXASuSE-OtaaCmj5w",
          "sg_message_id": "tk_wpzmPSMGGQ3HWqJ6Bkg.filter0109p3las1-17392-5BE02D7C-B.0",
          "useragent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14) AppleWebKit/605.1.15 (KHTML, like Gecko)",
          "event": "bounce"
        }
      ]}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(204)
      @email.reload
      expect(@email.bounced_count).to eq 1
    end
  end

  private

  def open_json
    { _json: [
      {
        "email": "test1@mail.net",
        "timestamp": Time.now.to_i,
        "ip": "77.222.3.247",
        "sg_event_id": "E_1GuLXASuSE-OtaaCmj5w",
        "sg_message_id": "tk_wpzmPSMGGQ3HWqJ6Bkg.filter0109p3las1-17392-5BE02D7C-B.0",
        "useragent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14) AppleWebKit/605.1.15 (KHTML, like Gecko)",
        "event": "open"
      }
    ]}.to_json
  end
end
