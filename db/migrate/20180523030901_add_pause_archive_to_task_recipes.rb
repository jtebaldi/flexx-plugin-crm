class AddPauseArchiveToTaskRecipes < ActiveRecord::Migration
  def change
    add_column :task_recipes, :archived, :boolean, default: false
    add_column :task_recipes, :archived_by, :integer
    add_column :task_recipes, :archived_at, :datetime
    add_column :task_recipes, :paused, :boolean, default: true
    add_column :task_recipes, :paused_by, :integer
    add_column :task_recipes, :paused_at, :datetime
  end
end
