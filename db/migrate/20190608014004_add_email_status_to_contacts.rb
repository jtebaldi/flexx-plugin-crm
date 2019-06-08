class AddEmailStatusToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :email_status, :string
  end
end
