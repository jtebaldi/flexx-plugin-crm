class AddSiteIdToPhonenumbers < ActiveRecord::Migration
  def change
    add_column :phonenumbers, :site_id, :integer
  end
end
