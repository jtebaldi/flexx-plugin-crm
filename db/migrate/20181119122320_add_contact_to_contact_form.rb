class AddContactToContactForm < ActiveRecord::Migration
  def change
    add_reference :plugins_contact_forms, :contact, index: true, foreign_key: true
  end
end
