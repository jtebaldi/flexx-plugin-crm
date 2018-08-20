class AddUserTrackingToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :created_by, :integer
    add_column :contacts, :updated_by, :integer
  end
end
