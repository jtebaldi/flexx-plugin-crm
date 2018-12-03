class Plugins::FlexxPluginCrm::TaskRecipe < ActiveRecord::Base
  self.table_name = 'task_recipes'

  has_many :directions, class_name: 'Plugins::FlexxPluginCrm::TaskRecipeDirection'
  has_many :task_recipe_to_contact_form_associations, class_name: 'Plugins::FlexxPluginCrm::TaskRecipeToContactFormAssociation'
  has_many :cama_contact_forms, class_name: 'Plugins::CamaContactForm::CamaContactForm', through: :task_recipe_to_contact_form_associations

  scope :active, -> { where(archived: false, paused: false) }
  scope :paused, -> { where(paused: true, archived: false) }
  scope :shared, -> { where(shared: true, archived: false) }

  def ordered_directions
    directions.sort_by { |row| row.due_on_value.send(row.due_on_unit).to_i }
  end
end
