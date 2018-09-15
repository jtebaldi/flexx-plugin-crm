class AddFromToEmail < ActiveRecord::Migration
  def change
    add_column :emails, :from, :string
  end
end
