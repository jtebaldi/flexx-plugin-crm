class Plugins::FlexxPluginCrm::TaskRecipeDirection < ActiveRecord::Base
  self.table_name = 'task_recipe_directions'

  belongs_to :task_recipe, class_name: 'Plugins::FlexxPluginCrm::TaskRecipe'
end
