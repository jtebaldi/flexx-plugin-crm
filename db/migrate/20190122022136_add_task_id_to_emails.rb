class AddTaskIdToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :task_id, :integer
  end
end
