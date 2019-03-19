module Plugins::FlexxPluginCrm::MainHelper
  def self.included(klass)
  end

  def flexx_plugin_admin_before_load
    # Temporarily removed icon until we're ready to go live
    # admin_menu_insert_menu_after("dashboard", "crm", {icon: 'briefcase', title: 'CRM', url: admin_contacts_path})
  end

  def flexx_plugin_crm_on_active(plugin)
    init_default_settings(plugin.site)

    if plugin.site.get_option("flexx_crm_list_id").blank?
      list_name = "#{Digest::MD5.hexdigest(plugin.site.slug)}#{SecureRandom.hex(5)}"

      plugin.site.set_option("flexx_crm_list_name", list_name)

      list_id = SendgridService.new.create_list(name: list_name)

      plugin.site.set_option("flexx_crm_list_id", list_id) if list_id.present?
    end

    plugin
  end

  def flexx_plugin_crm_on_inactive(plugin)
  end

  def flexx_plugin_crm_on_upgrade(plugin)
  end

  def flexx_plugin_crm_on_plugin_options(args)
  end

  def flexx_plugin_crm_on_contact_form_after_submit(args)
    add_activity_feed args
    send_stock_email_response args
    apply_tags_to_contact args
  end

  private

  def init_default_settings(site)
    site.set_meta("flexx_crm_settings", {
      country_code: '+1'
    }) unless site.get_meta("flexx_crm_settings").present? && site.get_meta("flexx_crm_settings")[:country_code].present?
  end

  def add_activity_feed(args)
    suffix = args[:form_received].contact.present? ? "completed by #{args[:form_received].contact.print_name}." : "completed."

    activity_record_params = {
      feed_name: 'notifications',
      feed_id: args[:form].site_id,
      args: {
        actor: "Contact:#{args[:form_received].contact_id}",
        verb: 'form_completed',
        object: "Form:#{args[:form].id}",
        message: "Form #{args[:form].name} #{suffix}",
        url: args[:form_received].contact.present? ? admin_contact_path(args[:form_received].contact_id) : ''
      }
    }

    ActivityFeedWorker.perform_async(activity_record_params.to_json)
  end

  def send_stock_email_response(args)
    return unless args[:form].the_settings.try(:[], 'railscf_response').try(:[], 'enabled') == 'true'

    stock_email = args[:form].site.stocks.rich_texts.find_by(id: args[:form].the_settings[:railscf_response][:stock_id])

    return if stock_email.blank?

    args[:form].site.emails.create({
      from: args[:form].the_settings[:railscf_response][:from],
      subject: stock_email.metadata['subject'],
      body: stock_email.contents,
      recipients_list: args[:form_received].contact_id,
      send_at: Time.current
    })
  end

  def apply_tags_to_contact(args)
    return unless args[:form].the_settings.try(:[], 'railscf_tags').try(:[], 'list').present?

    args[:form].site.tag(args[:form_received].contact, with: args[:form].the_settings[:railscf_tags][:list], on: :tags)
  end
end
