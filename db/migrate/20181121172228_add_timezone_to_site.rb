class AddTimezoneToSite < ActiveRecord::Migration
  def change
    add_column "#{PluginRoutes.static_system_info["db_prefix"]}term_taxonomy", :timezone, :string
  end
end
