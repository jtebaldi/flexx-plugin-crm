class AddTaskToEmailRecipient < ActiveRecord::Migration
  def change
    add_reference :email_recipients, :task, index: true, foreign_key: true
  end
end
