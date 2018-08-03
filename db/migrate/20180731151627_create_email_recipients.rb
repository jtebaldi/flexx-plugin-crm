class CreateEmailRecipients < ActiveRecord::Migration
  def change
    create_table :email_recipients do |t|
      t.string :email_id
      t.string :to
      t.string :status
    end
  end
end
