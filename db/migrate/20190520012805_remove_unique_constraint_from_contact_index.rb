class RemoveUniqueConstraintFromContactIndex < ActiveRecord::Migration
  def change
    remove_index :contacts, [:site_id, :email]
    add_index :contacts, [:site_id, :email]
  end
end
