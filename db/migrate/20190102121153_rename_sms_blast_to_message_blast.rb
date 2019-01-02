class RenameSmsBlastToMessageBlast < ActiveRecord::Migration
  def change
    rename_table :sms_blasts, :message_blasts
  end
end
