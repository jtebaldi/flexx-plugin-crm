class AddReplyMessageIdToEmail < ActiveRecord::Migration
  def change
    add_column :emails, :reply_message_id, :string
    add_index :emails, :reply_message_id
  end
end
