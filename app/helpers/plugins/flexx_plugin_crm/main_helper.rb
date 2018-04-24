module Plugins::FlexxPluginCrm::MainHelper
  def self.included(klass)
  end

  def flexx_plugin_admin_before_load
    admin_menu_insert_menu_after("dashboard", "crm", {icon: 'briefcase', title: 'CRM', url: admin_plugins_flexx_plugin_crm_index_path})
    admin_menu_append_menu_item("settings", {icon: "briefcase", title: "CRM Settings", url: admin_plugins_flexx_plugin_crm_settings_path})
  end

  def flexx_plugin_crm_on_active(plugin)
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
    args[:links] << link_to('Settings', admin_plugins_flexx_plugin_crm_settings_path)
  end

  def flexx_plugin_crm_on_contact_form_after_submit(args)
    cids = {}
    args[:form].fields.each do |f|
      cids[:email] = f["cid"] if f["field_type"] == "email"
    end

    contact = Plugins::FlexxPluginCrm::Contact.find_or_create_by(
      site_id: current_site.id,
      email: args[:values][cids[:email]]
    )

    contact.source = "Form - #{args[:form][:name]}" if contact.source.blank?
    contact.save
  end
end
