class RenameContactFormId < ActiveRecord::Migration
  def change
    rename_column :task_recipe_to_contact_form_associations, :contact_form_id, :cama_contact_form_id
  end
end
