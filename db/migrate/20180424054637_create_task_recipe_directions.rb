class CreateTaskRecipeDirections < ActiveRecord::Migration
  def change
    create_table :task_recipe_directions do |t|
      t.integer :task_recipe_id
      t.string :task_type
      t.integer :due_on_value
      t.string :due_on_unit
      t.string :title
      t.string :details
      t.integer :created_by

      t.timestamps null: false
    end
  end
end
