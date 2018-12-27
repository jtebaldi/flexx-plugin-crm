class AddAvatarToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :avatar_uid, :string
  end
end
