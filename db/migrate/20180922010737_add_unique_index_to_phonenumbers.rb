class AddUniqueIndexToPhonenumbers < ActiveRecord::Migration
  def change
    add_index :phonenumbers, [:site_id, :number], unique: true
  end
end
