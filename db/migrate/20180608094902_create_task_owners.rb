class CreateTaskOwners < ActiveRecord::Migration
  def change
    create_table :task_owners do |t|
      t.integer :task_id, null: false
      t.integer :owner_id, null: false

      t.timestamps null: false
    end
  end
end
