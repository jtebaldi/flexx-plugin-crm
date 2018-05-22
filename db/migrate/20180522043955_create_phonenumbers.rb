class CreatePhonenumbers < ActiveRecord::Migration
  def change
    create_table :phonenumbers do |t|
      t.integer :contact_id, null: false
      t.string :number, null: false
      t.string :phone_type, null: false

      t.timestamps null: false
    end
  end
end
