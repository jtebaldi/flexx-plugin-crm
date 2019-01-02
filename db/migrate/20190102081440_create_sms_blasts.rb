class CreateSmsBlasts < ActiveRecord::Migration
  def change
    create_table :sms_blasts do |t|
      t.integer :site_id, index: true, null: false
      t.string :recipients_list, null: false
      t.json :recipients_label
      t.integer :recipients_count
      t.string :message, null: false
      t.integer :delivered_count, default: 0
      t.datetime :send_at, null: false, index: true
      t.string :aasm_state, null: false, index: true

      t.integer :created_by, null: false

      t.timestamps null: false
    end
  end
end
