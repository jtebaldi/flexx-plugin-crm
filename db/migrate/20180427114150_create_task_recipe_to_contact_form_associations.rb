class CreateTaskRecipeToContactFormAssociations < ActiveRecord::Migration
  def change
    create_table :task_recipe_to_contact_form_associations do |t|
      t.integer :task_recipe_id
      t.integer :contact_form_id

      t.timestamps null: false
    end
  end
end
