class AddUnarhivedAtToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :unarchived_at, :datetime
  end
end
