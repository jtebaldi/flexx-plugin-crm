class AddOriginalCreatorToTaskRecipe < ActiveRecord::Migration
  def change
    add_column :task_recipes, :original_site_id, :integer
  end
end
