class TaskRecipeService
  def self.apply_recipes(contact:)
    contact.cama_contact_form.parent.task_recipes.active.each { |recipe| apply_recipe(contact: contact, recipe: recipe) }
  end

  def self.apply_recipe(contact:, recipe:)
    recipe.directions.each do |direction|
      contact.tasks.create(
        site_id: contact.site_id,
        task_type: direction.task_type,
        title: direction.title,
        details: direction.details,
        due_date: Time.now + direction.due_on_value.send(direction.due_on_unit)
      )
    end
  end
end
