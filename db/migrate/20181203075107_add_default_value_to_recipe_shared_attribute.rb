class AddDefaultValueToRecipeSharedAttribute < ActiveRecord::Migration
  def change
    change_column :task_recipes, :shared, :boolean, :default => false
  end
end
