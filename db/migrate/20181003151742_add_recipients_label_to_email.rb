class AddRecipientsLabelToEmail < ActiveRecord::Migration
  def change
    add_column :emails, :recipients_label, :json
  end
end
