class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :site_id
      t.string :sendgrid_id
      t.string :source
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :sales_stage

      t.timestamps null: false
    end

    add_index :contacts, [:site_id, :email], unique: true
  end
end
