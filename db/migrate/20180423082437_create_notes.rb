class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :details
      t.integer :parent_id
      t.string :parent_type
      t.integer :created_by

      t.timestamps null: false
    end

    add_index :notes, [:parent_type, :parent_id]
  end
end
