class AddSendAtToEmailMessage < ActiveRecord::Migration
  def change
    add_column :emails, :send_at, :datetime
    add_column :messages, :send_at, :datetime
  end
end
