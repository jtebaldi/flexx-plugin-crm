class AddContactIdToEmailRecipients < ActiveRecord::Migration
  def change
    add_column :email_recipients, :contact_id, :integer
  end
end
