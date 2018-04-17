class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :contact_id
      t.integer :site_id
      t.string :task_type
      t.string :title
      t.string :details
      t.datetime :due_date
      t.string :aasm_state
      t.integer :created_by
      t.integer :updated_by

      t.timestamps null: false
    end
  end
end
