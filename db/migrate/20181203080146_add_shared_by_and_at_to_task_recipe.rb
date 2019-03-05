class AddSharedByAndAtToTaskRecipe < ActiveRecord::Migration
  def change
    add_column :task_recipes, :shared_by, :integer
    add_column :task_recipes, :shared_at, :datetime
  end
end
