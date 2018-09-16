class AddReadToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :read, :boolean, default: false
    add_index :messages, :read
  end
end
