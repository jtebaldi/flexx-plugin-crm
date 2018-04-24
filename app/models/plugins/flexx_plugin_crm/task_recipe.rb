class Plugins::FlexxPluginCrm::TaskRecipe < ActiveRecord::Base
  self.table_name = 'task_recipes'

  has_many :directions, class_name: 'Plugins::FlexxPluginCrm::TaskRecipeDirection'
end
