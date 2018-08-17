class AddDetailsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :address1, :string
    add_column :contacts, :address2, :string
    add_column :contacts, :city, :string
    add_column :contacts, :state, :string
    add_column :contacts, :postal_code, :string
    add_column :contacts, :country, :string
    add_column :contacts, :birthday, :date
  end
end
