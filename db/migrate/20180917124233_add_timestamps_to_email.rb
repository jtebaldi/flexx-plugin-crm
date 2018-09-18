class AddTimestampsToEmail < ActiveRecord::Migration
  def up
    add_timestamps :emails, default: Date.today
    change_column_default :emails, :created_at, nil
    change_column_default :emails, :updated_at, nil
  end

  def down
    remove_column :emails, :created_at
    remove_column :emails, :updated_at
  end
end
