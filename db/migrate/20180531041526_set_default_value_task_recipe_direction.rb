class SetDefaultValueTaskRecipeDirection < ActiveRecord::Migration
  def change
    change_column :task_recipe_directions, :due_on_value, :integer, null:false, default: 0
    change_column :task_recipe_directions, :due_on_unit, :string, null: false, default: 'minutes'
  end
end
