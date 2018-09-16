class AddIndexesToMessages < ActiveRecord::Migration
  def change
    add_index :messages, :created_at
    add_index :messages, :contact_id
    add_index :messages, :site_id
    add_index :messages, :from_number
    add_index :messages, :to_number
  end
end
