class AddNumberColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :chats, :number, :integer, null: false
    add_column :messages, :number, :integer, null: false
  end
end
