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
    # cids = args[:form].fields.reduce({}) do |h, f|
    #   if f['field_type'] == 'email'
    #     h.merge email: f['cid']
    #   else
    #     case f['label'].downcase when 'first name' then h.merge(first_name: f['cid'])
    #     when 'last name' then h.merge(last_name: f['cid'])
    #     when 'name' then h.merge(name: f['cid'])
    #     when 'phone number' then h.merge(phone_number: f['cid'])
    #     else h
    #     end
    #   end
    # end

    # return if Plugins::FlexxPluginCrm::Contact.exists?(site_id: current_site.id, email: args[:values][cids[:email]])

    # first_name = last_name = ''
    # if cids[:first_name] && cids[:last_name]
    #   first_name = args[:values][cids[:first_name]]
    #   last_name = args[:values][cids[:last_name]]
    # elsif cids[:name]
    #   first_name, last_name = args[:values][cids[:name]].split ' '
    # end

    # contact = Plugins::FlexxPluginCrm::Contact.create(
    #   site_id: current_site.id,
    #   first_name: first_name,
    #   last_name: last_name,
    #   email: args[:values][cids[:email]],
    #   source: "Form - #{args[:form][:name]}",
    #   cama_contact_form_id: args[:form].id
    # )
    # contact.phonenumbers.create number: args[:values][cids[:phone_number]]

    # TaskRecipeService.apply_recipes(contact: contact)

    # Rails.logger.warn('RECIPES')

    # AutomatedCampaignService.apply_campaigns(contact: contact)
  end

  private

  def init_default_settings(site)
    site.set_meta("flexx_crm_settings", {
      country_code: '+1'
    }) unless site.get_meta("flexx_crm_settings").present? && site.get_meta("flexx_crm_settings")[:country_code].present?
  end
end
