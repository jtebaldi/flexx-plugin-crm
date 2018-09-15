class ChangeEmailIdToBeIntegerInEmailRecipients < ActiveRecord::Migration
  def up
    change_column :email_recipients, :email_id, 'integer USING CAST(email_id AS integer)'
  end

  def down
    change_column :email_recipients, :email_id, :string
  end
end
