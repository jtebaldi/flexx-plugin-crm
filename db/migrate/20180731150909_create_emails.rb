class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :sg_message_id
      t.integer :site_id
      t.string :subject
      t.text :body
      t.integer :created_by
    end
    add_index :emails, :sg_message_id
  end
end
