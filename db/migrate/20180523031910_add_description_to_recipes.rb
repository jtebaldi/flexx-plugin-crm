class AddDescriptionToRecipes < ActiveRecord::Migration
  def change
    add_column :task_recipes, :description, :string
  end
end
