class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :task_recipes do |t|
      t.string :title
      t.integer :created_by
      t.integer :site_id

      t.timestamps null: false
    end
  end
end
