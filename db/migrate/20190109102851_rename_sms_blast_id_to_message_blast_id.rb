class RenameSmsBlastIdToMessageBlastId < ActiveRecord::Migration
  def change
    rename_column :messages, :sms_blast_id, :message_blast_id
  end
end
