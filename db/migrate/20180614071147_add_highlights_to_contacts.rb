class AddHighlightsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :highlights, :text
  end
end
