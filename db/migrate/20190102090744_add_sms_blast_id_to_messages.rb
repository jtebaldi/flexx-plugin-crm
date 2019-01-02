class AddSmsBlastIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :sms_blast_id, :integer, index: true
  end
end
