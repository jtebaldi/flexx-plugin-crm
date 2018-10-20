class AddAasmStateIndexToEmails < ActiveRecord::Migration
  def change
    add_index :emails, :aasm_state
  end
end
