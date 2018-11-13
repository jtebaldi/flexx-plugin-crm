class AddDeliveredBouncedToEmailRecipient < ActiveRecord::Migration
  def change
    add_column :email_recipients, :delivered_at, :datetime
    add_column :email_recipients, :bounced_at, :datetime
  end
end
