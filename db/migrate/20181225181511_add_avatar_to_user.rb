class AddAvatarToUser < ActiveRecord::Migration
  def change
    add_column "#{PluginRoutes.static_system_info["db_prefix"]}users", :avatar_uid, :string
  end
end
