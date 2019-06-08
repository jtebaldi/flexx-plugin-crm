class AddDroppedCounterAndSpamCounterToEmail < ActiveRecord::Migration
  def change
    add_column :emails, :dropped_count, :integer, default: 0
    add_column :emails, :spam_count, :integer, default: 0
  end
end
