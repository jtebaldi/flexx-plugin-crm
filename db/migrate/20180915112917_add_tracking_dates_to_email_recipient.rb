class AddTrackingDatesToEmailRecipient < ActiveRecord::Migration
  def change
    add_column :email_recipients, :opened_at, :datetime
    add_column :email_recipients, :clicked_at, :datetime
    add_column :email_recipients, :unsubscribed_at, :datetime
  end
end
