class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :contact_id
      t.integer :site_id
      t.string :sid
      t.string :from_number
      t.string :to_number
      t.text :message
      t.string :status
      t.integer :created_by

      t.timestamps null: false
    end
  end
end
