class AddAasmStateToEmailMessage < ActiveRecord::Migration
  def change
    add_column :emails, :aasm_state, :string
    add_column :messages, :aasm_state, :string
  end
end
