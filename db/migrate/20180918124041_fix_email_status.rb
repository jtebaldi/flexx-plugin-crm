class FixEmailStatus < ActiveRecord::Migration
  def change
    change_column_null :emails, :status, false, 'draft'
  end
end
