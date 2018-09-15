class AddFieldsToEmail < ActiveRecord::Migration
  def change
    add_column :emails, :recipients_count, :integer
    add_column :emails, :opened_count, :integer, default: 0
    add_column :emails, :clicked_count, :integer, default: 0
    add_column :emails, :bounced_count, :integer, default: 0
    add_column :emails, :unsubscribed_count, :integer, default: 0
    add_column :emails, :recipients_list, :string
    add_column :emails, :status, :string
    add_column :emails, :send_at, :datetime
  end
end
