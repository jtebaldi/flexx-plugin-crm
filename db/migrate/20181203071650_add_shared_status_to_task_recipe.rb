class AddSharedStatusToTaskRecipe < ActiveRecord::Migration
  def change
    add_column :task_recipes, :shared, :boolean
  end
end
