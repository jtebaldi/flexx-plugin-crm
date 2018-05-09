class AddCamaContactFormIdToContact < ActiveRecord::Migration
  def change
      add_column :contacts, :cama_contact_form_id, :integer
  end
end
