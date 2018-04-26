class Plugins::FlexxPluginCrm::TaskRecipe < ActiveRecord::Base
  self.table_name = 'task_recipes'

  has_many :directions, class_name: 'Plugins::FlexxPluginCrm::TaskRecipeDirection'

  def ordered_directions
    directions.sort_by { |row| row.due_on_value.send(row.due_on_unit).to_i }
  end
end
