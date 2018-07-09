class AddConfirmationToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :confirmed_at, :datetime
  end
end
