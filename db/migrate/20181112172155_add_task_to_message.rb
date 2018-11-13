class AddTaskToMessage < ActiveRecord::Migration
  def change
    add_reference :messages, :task, index: true, foreign_key: true
  end
end
